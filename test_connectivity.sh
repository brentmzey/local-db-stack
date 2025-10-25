#!/bin/bash
# End-to-End Connectivity Test for Local DB Stack
# Tests that applications can connect to all databases from anywhere

set -e

echo "🔌 Testing Local DB Stack End-to-End Connectivity..."
echo "   This verifies that client applications can connect to all databases"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test results
PASSED=0
FAILED=0

test_connection() {
    local name=$1
    local command=$2
    
    echo -e "${BLUE}Testing $name...${NC}"
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ $name connection successful${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}  ✗ $name connection failed${NC}"
        ((FAILED++))
        return 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TEST 1: Container Health Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Wait for containers to be healthy
echo -e "${YELLOW}Waiting for containers to be healthy (may take 30-60 seconds)...${NC}"
sleep 15

# Check container health
for container in local_postgres local_mysql local_mongodb local_redis; do
    status=$(docker inspect --format='{{.State.Health.Status}}' $container 2>/dev/null || echo "not found")
    if [ "$status" = "healthy" ]; then
        echo -e "${GREEN}  ✓ $container is healthy${NC}"
        ((PASSED++))
    elif [ "$status" = "not found" ]; then
        echo -e "${RED}  ✗ $container not found${NC}"
        ((FAILED++))
    else
        echo -e "${YELLOW}  ⚠ $container status: $status (may need more time)${NC}"
    fi
done

# Oracle doesn't have health check initially
oracle_status=$(docker inspect --format='{{.State.Status}}' local_oracle 2>/dev/null || echo "not found")
if [ "$oracle_status" = "running" ]; then
    echo -e "${GREEN}  ✓ local_oracle is running${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}  ⚠ local_oracle status: $oracle_status${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TEST 2: Direct Client Connections (CLI Tools)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# PostgreSQL via psql
test_connection "PostgreSQL (psql)" \
    "docker exec local_postgres psql -U local_user -d local_database -c 'SELECT 1'"

# MySQL via mysql client
test_connection "MySQL (mysql client)" \
    "docker exec local_mysql mysql -ulocal_user -plocal_password -e 'SELECT 1'"

# MongoDB via mongosh
test_connection "MongoDB (mongosh)" \
    "docker exec local_mongodb mongosh -u local_root -p local_rootpassword --authenticationDatabase admin --quiet --eval 'db.version()'"

# Redis via redis-cli
test_connection "Redis (redis-cli)" \
    "docker exec local_redis redis-cli PING"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TEST 3: External Port Connectivity (Application Access)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# PostgreSQL via external port
if command -v psql &> /dev/null; then
    test_connection "PostgreSQL (external port 15432)" \
        "PGPASSWORD=local_password psql -h localhost -p 15432 -U local_user -d local_database -c 'SELECT 1'"
else
    echo -e "${YELLOW}  ⚠ psql not installed - skipping external port test${NC}"
fi

# MySQL via external port  
if command -v mysql &> /dev/null; then
    test_connection "MySQL (external port 13306)" \
        "mysql -h localhost -P 13306 -ulocal_user -plocal_password -e 'SELECT 1'"
else
    echo -e "${YELLOW}  ⚠ mysql not installed - skipping external port test${NC}"
fi

# MongoDB via external port
if command -v mongosh &> /dev/null; then
    test_connection "MongoDB (external port 17017)" \
        "mongosh 'mongodb://local_root:local_rootpassword@localhost:17017/admin?authSource=admin' --quiet --eval 'db.version()'"
else
    echo -e "${YELLOW}  ⚠ mongosh not installed - skipping external port test${NC}"
fi

# Redis via external port
if command -v redis-cli &> /dev/null; then
    test_connection "Redis (external port 16379)" \
        "redis-cli -p 16379 PING"
else
    echo -e "${YELLOW}  ⚠ redis-cli not installed - skipping external port test${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TEST 4: Data Operations (Write & Read)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# PostgreSQL write/read
TEST_TIME=$(date +%s)
docker exec local_postgres psql -U local_user -d local_database -c "CREATE TABLE IF NOT EXISTS connectivity_test (id SERIAL PRIMARY KEY, test_time BIGINT);" > /dev/null 2>&1
docker exec local_postgres psql -U local_user -d local_database -c "INSERT INTO connectivity_test (test_time) VALUES ($TEST_TIME);" > /dev/null 2>&1
PG_RESULT=$(docker exec local_postgres psql -U local_user -d local_database -t -c "SELECT test_time FROM connectivity_test WHERE test_time = $TEST_TIME;")
if [ -n "$PG_RESULT" ]; then
    echo -e "${GREEN}  ✓ PostgreSQL write/read successful${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ✗ PostgreSQL write/read failed${NC}"
    ((FAILED++))
fi

# MySQL write/read
docker exec local_mysql mysql -ulocal_user -plocal_password local_database -e "CREATE TABLE IF NOT EXISTS connectivity_test (id INT AUTO_INCREMENT PRIMARY KEY, test_time BIGINT);" > /dev/null 2>&1
docker exec local_mysql mysql -ulocal_user -plocal_password local_database -e "INSERT INTO connectivity_test (test_time) VALUES ($TEST_TIME);" > /dev/null 2>&1
MYSQL_RESULT=$(docker exec local_mysql mysql -ulocal_user -plocal_password local_database -sN -e "SELECT test_time FROM connectivity_test WHERE test_time = $TEST_TIME;")
if [ -n "$MYSQL_RESULT" ]; then
    echo -e "${GREEN}  ✓ MySQL write/read successful${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ✗ MySQL write/read failed${NC}"
    ((FAILED++))
fi

# MongoDB write/read
docker exec local_mongodb mongosh -u local_root -p local_rootpassword --authenticationDatabase admin --quiet --eval "db.getSiblingDB('testdb').connectivity_test.insertOne({test_time: $TEST_TIME})" > /dev/null 2>&1
MONGO_RESULT=$(docker exec local_mongodb mongosh -u local_root -p local_rootpassword --authenticationDatabase admin --quiet --eval "db.getSiblingDB('testdb').connectivity_test.findOne({test_time: $TEST_TIME})" 2>/dev/null)
if [ -n "$MONGO_RESULT" ]; then
    echo -e "${GREEN}  ✓ MongoDB write/read successful${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ✗ MongoDB write/read failed${NC}"
    ((FAILED++))
fi

# Redis write/read
docker exec local_redis redis-cli SET "connectivity_test_$TEST_TIME" "success" > /dev/null 2>&1
REDIS_RESULT=$(docker exec local_redis redis-cli GET "connectivity_test_$TEST_TIME")
if [ "$REDIS_RESULT" = "success" ]; then
    echo -e "${GREEN}  ✓ Redis write/read successful${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ✗ Redis write/read failed${NC}"
    ((FAILED++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TEST 5: Connection Strings (Application Integration)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Connection strings for your applications:"
echo ""
echo -e "${BLUE}PostgreSQL:${NC}"
echo "  postgresql://local_user:local_password@localhost:15432/local_database"
echo ""
echo -e "${BLUE}MySQL:${NC}"
echo "  mysql://local_user:local_password@localhost:13306/local_database"
echo ""
echo -e "${BLUE}MongoDB:${NC}"
echo "  mongodb://local_root:local_rootpassword@localhost:17017/admin?authSource=admin"
echo ""
echo -e "${BLUE}Redis:${NC}"
echo "  redis://localhost:16379"
echo ""
echo -e "${BLUE}Oracle:${NC}"
echo "  oracle://system:local_password@localhost:11521/FREEPDB1"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TEST SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All connectivity tests passed!${NC}"
    echo "  Your applications can now connect to all databases using the connection strings above."
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠ Some tests failed. Check the output above for details.${NC}"
    echo "  Common issues:"
    echo "  - Containers may need more time to become healthy (wait 60s and retry)"
    echo "  - Client tools may not be installed (install via: brew install libpq mysql-client mongosh redis)"
    echo ""
    exit 1
fi
