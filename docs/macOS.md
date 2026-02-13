# WinApps on macOS

Run Windows applications on macOS via RDP RemoteApp, using the system RDP client (Microsoft "Windows App").

## Prerequisites

1. **Microsoft "Windows App"** (free) from the Mac App Store
2. A **Windows machine with RDP enabled** (VM, remote server, or local Parallels/UTM)
3. **RDP RemoteApp configured** on the Windows machine (merge `install/RDPApps.reg`)

## Installation

### Via Homebrew (recommended)

```bash
brew tap dingyifei/winapps
brew install winapps
```

### Manual

```bash
git clone https://github.com/dingyifei/winapps.git
cd winapps
```

## Configuration

Create the config file:

```bash
mkdir -p ~/.config/winapps
cat > ~/.config/winapps/winapps.conf << 'EOF'
RDP_IP=192.168.1.100
RDP_USER=MyWindowsUser
RDP_PASS=MyPassword
RDP_DOMAIN=WORKGROUP
EOF
```

Set `RDP_IP` to your Windows machine's IP address. Unlike Linux, macOS does not support KVM auto-detection, so `RDP_IP` is required.

## Windows Setup

1. Enable Remote Desktop on the Windows machine
2. Import the RemoteApp registry settings:
   - Copy `install/RDPApps.reg` to the Windows machine
   - Double-click to merge it into the registry
3. Optionally run `install/ExtractPrograms.ps1` to verify app detection

## Usage

```bash
# Test connectivity
winapps check

# Full Windows desktop
winapps windows

# Launch a pre-configured app
winapps word
winapps excel

# Launch an app with a file
winapps word ~/Documents/report.docx

# Launch any Windows executable
winapps manual "C:\Windows\System32\notepad.exe"

# See all commands
winapps --help
```

## Install App Shortcuts

Run the installer to create CLI wrappers for detected apps:

```bash
# User install (~/.local/bin)
./installer.sh --user

# System install (/usr/local/bin)
./installer.sh --system
```

On macOS, the installer skips `.desktop` file creation (Linux-only) and creates CLI wrappers only.

## How It Works

On macOS, WinApps generates `.rdp` files dynamically and opens them with the system `open` command, which delegates to Microsoft "Windows App". This avoids the FreeRDP/XQuartz dependency chain that was problematic on macOS.

- `winapps word` generates a temporary `.rdp` file with RemoteApp settings and opens it
- `winapps windows` generates a full desktop `.rdp` file
- Files passed as arguments are mapped through `\\tsclient\home` (drive redirection)

## Credential Handling

Passwords are not stored in `.rdp` files for security. The RDP client will prompt for credentials on first connection and can save them in the macOS Keychain.

## Troubleshooting

- **"Windows App" not opening**: Ensure it's installed from the Mac App Store
- **Connection refused**: Verify `RDP_IP` is correct and RDP is enabled on Windows
- **RemoteApp not working**: Ensure `install/RDPApps.reg` was merged on the Windows machine
- **Files not accessible**: Check that drive redirection is enabled (it is by default in generated `.rdp` files)
