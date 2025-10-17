class LocalDbStack < Formula
  desc "Isolated, namespaced local database stack for macOS"
  homepage "https://github.com/brentmzey/local-db-stack"
  url "https://github.com/brentmzey/local-db-stack/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "YOUR_SHA256_CHECKSUM_HERE" # Update this after creating a release
  license "MIT"
  depends_on "docker"
  depends_on "docker-compose"
  def install
    libexec.install "assets/docker-compose.yml", "assets/.env.example", "assets/shell_config.sh"
    bin.install "install.sh" => "localdb-setup"
  end
  def caveats
    <<~EOS
      To complete the setup, run the following one-time command:
        localdb-setup
      Then, restart your terminal.
    EOS
  end
end
