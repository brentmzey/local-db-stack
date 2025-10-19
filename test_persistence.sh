#!/bin/bash
# Data Persistence Test for Local DB Stack
# This script tests that data persists across container restarts

set -e

echo "🧪 Testing Local DB Stack Data Persistence..."
echo ""

COMPOSE_CMD="docker-compose -f assets/docker-compose.yml --env-file assets/.env.example"

# Test PostgreSQL
echo "📊 Testing PostgreSQL..."
docker exec local_postgres psql -U local_user -d local_database -c "CREATE TABLE IF NOT EXISTS test_data (id SERIAL PRIMARY KEY, value TEXT);"
docker exec local_postgres psql -U local_user -d local_database -c "INSERT INTO test_data (value) VALUES ('persistence_test_$(date +%s)');"
PG_COUNT_BEFORE=$(docker exec local_postgres psql -U local_user -d local_database -t -c "SELECT COUNT(*) FROM test_data;")
echo "  ✓ PostgreSQL: $PG_COUNT_BEFORE row(s) before restart"

# Test MySQL
echo "📊 Testing MySQL..."
docker exec local_mysql mysql -ulocal_user -plocal_password local_database -e "CREATE TABLE IF NOT EXISTS test_data (id INT AUTO_INCREMENT PRIMARY KEY, value VARCHAR(255));"
docker exec local_mysql mysql -ulocal_user -plocal_password local_database -e "INSERT INTO test_data (value) VALUES ('persistence_test_$(date +%s)');"
MYSQL_COUNT_BEFORE=$(docker exec local_mysql mysql -ulocal_user -plocal_password local_database -sN -e "SELECT COUNT(*) FROM test_data;")
echo "  ✓ MySQL: $MYSQL_COUNT_BEFORE row(s) before restart"

# Test MongoDB
echo "📊 Testing MongoDB..."
docker exec local_mongodb mongosh -u local_root -p local_rootpassword --authenticationDatabase admin --quiet --eval "db.getSiblingDB('testdb').testcol.insertOne({value: 'persistence_test_$(date +%s)'})"
MONGO_COUNT_BEFORE=$(docker exec local_mongodb mongosh -u local_root -p local_rootpassword --authenticationDatabase admin --quiet --eval "db.getSiblingDB('testdb').testcol.countDocuments()" | tail -1)
echo "  ✓ MongoDB: $MONGO_COUNT_BEFORE document(s) before restart"

# Test Redis
echo "📊 Testing Redis..."
REDIS_KEY="test_key_$(date +%s)"
docker exec local_redis redis-cli SET "$REDIS_KEY" "persistence_test"
docker exec local_redis redis-cli BGSAVE > /dev/null
sleep 1  # Wait for background save
REDIS_KEYS_BEFORE=$(docker exec local_redis redis-cli DBSIZE | awk '{print $2}')
echo "  ✓ Redis: $REDIS_KEYS_BEFORE key(s) before restart"

echo ""
echo "🔄 Restarting all containers..."
$COMPOSE_CMD restart > /dev/null 2>&1
echo "  ⏳ Waiting for containers to be healthy..."
sleep 10

echo ""
echo "🔍 Verifying data persistence..."

# Verify PostgreSQL
PG_COUNT_AFTER=$(docker exec local_postgres psql -U local_user -d local_database -t -c "SELECT COUNT(*) FROM test_data;")
if [ "$PG_COUNT_BEFORE" = "$PG_COUNT_AFTER" ]; then
    echo "  ✅ PostgreSQL: Data persisted ($PG_COUNT_AFTER row(s))"
else
    echo "  ❌ PostgreSQL: Data LOST (before: $PG_COUNT_BEFORE, after: $PG_COUNT_AFTER)"
    exit 1
fi

# Verify MySQL
MYSQL_COUNT_AFTER=$(docker exec local_mysql mysql -ulocal_user -plocal_password local_database -sN -e "SELECT COUNT(*) FROM test_data;")
if [ "$MYSQL_COUNT_BEFORE" = "$MYSQL_COUNT_AFTER" ]; then
    echo "  ✅ MySQL: Data persisted ($MYSQL_COUNT_AFTER row(s))"
else
    echo "  ❌ MySQL: Data LOST (before: $MYSQL_COUNT_BEFORE, after: $MYSQL_COUNT_AFTER)"
    exit 1
fi

# Verify MongoDB
MONGO_COUNT_AFTER=$(docker exec local_mongodb mongosh -u local_root -p local_rootpassword --authenticationDatabase admin --quiet --eval "db.getSiblingDB('testdb').testcol.countDocuments()" | tail -1)
if [ "$MONGO_COUNT_BEFORE" = "$MONGO_COUNT_AFTER" ]; then
    echo "  ✅ MongoDB: Data persisted ($MONGO_COUNT_AFTER document(s))"
else
    echo "  ❌ MongoDB: Data LOST (before: $MONGO_COUNT_BEFORE, after: $MONGO_COUNT_AFTER)"
    exit 1
fi

# Verify Redis
REDIS_VALUE=$(docker exec local_redis redis-cli GET "$REDIS_KEY")
if [ "$REDIS_VALUE" = "persistence_test" ]; then
    echo "  ✅ Redis: Data persisted (key recovered)"
else
    echo "  ❌ Redis: Data LOST (key not found)"
    exit 1
fi

echo ""
echo "🎉 All data persistence tests passed!"
echo ""
echo "📋 Summary of Configuration:"
echo "  • All databases use durable write settings"
echo "  • PostgreSQL: fsync=on, synchronous_commit=on, full_page_writes=on"
echo "  • MySQL: innodb-flush-log-at-trx-commit=1, sync-binlog=1"
echo "  • MongoDB: WiredTiger journaling enabled"
echo "  • Redis: AOF + RDB persistence enabled"
echo "  • All volumes: Docker named volumes for maximum reliability"
