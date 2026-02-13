class Winapps < Formula
  desc "Run Windows apps on macOS via RDP RemoteApp"
  homepage "https://github.com/dingyifei/winapps"
  url "https://github.com/dingyifei/winapps/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER"
  license "MIT"

  def install
    bin.install "bin/winapps"
    (share/"winapps/apps").install Dir["apps/*"]
    (share/"winapps/install").install Dir["install/*"]
    (share/"winapps").install "installer.sh"
    (share/"winapps/icons").install "icons/windows.svg"
  end

  def caveats
    <<~EOS
      Prerequisites:
        Install Microsoft "Windows App" from the Mac App Store (free)
      Configure:
        mkdir -p ~/.config/winapps
        Edit ~/.config/winapps/winapps.conf with: RDP_IP, RDP_USER, RDP_PASS
      Test: winapps check
      Install app shortcuts: #{share}/winapps/installer.sh --system
    EOS
  end
end
