# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WinApps integrates Windows applications into Linux (Ubuntu/Fedora) and macOS desktops as if they were native apps. On Linux it uses FreeRDP to connect to a Windows RDP server (typically a KVM virtual machine). On macOS it generates `.rdp` files and delegates to Microsoft "Windows App" (the system RDP client). Both platforms create CLI wrappers for seamless launching; Linux also creates GNOME/KDE desktop entries.

**Language**: Bash (primary), PowerShell (Windows-side app detection)
**No build system** — all scripts are interpreted directly.

## Architecture

### Core Components

- **`bin/winapps`** — Main launcher. Reads user config, connects via FreeRDP (Linux) or generates `.rdp` files (macOS), launches Windows apps with file argument passthrough via `\\tsclient\home` mount. Supports full desktop (`winapps windows`) or single-app mode.
- **`installer.sh`** — Interactive installer handling `--user` (~/.local/) and `--system` (/usr/local/) modes. Scans the Windows VM for installed apps, creates `.desktop` files and CLI wrappers.
- **`install/inquirer.sh`** — Terminal UI library (arrow key navigation, checkbox/menu selection) used by the installer.
- **`install/ExtractPrograms.ps1`** — PowerShell script that runs on the Windows VM to query the registry for installed applications and extract icons.
- **`install/RDPApps.reg`** — Registry file enabling RDP remote app launching on Windows.

### Application Definitions

Each app in `apps/{app-name}/` contains exactly two files:
- **`info`** — Bash-sourced config with `NAME`, `FULL_NAME`, `WIN_EXECUTABLE`, `CATEGORIES`, `MIME_TYPES`
- **`icon.svg`** — Application icon

There are 55+ pre-configured apps (Office, Adobe CC, Visual Studio, etc.). To add a new app, create the directory with these two files.

### Installation Flow

```
installer.sh → waInstall() → waFindInstalled() (RDP scan) → waConfigureApps() → waConfigureDetectedApps()
```

The installer generates:
- `~/.local/share/applications/{app}.desktop` — Desktop shortcuts
- `~/.local/bin/{app}` — CLI wrapper scripts
- `~/.local/share/winapps/installed` — Detected app state

### User Configuration

Config is sourced from (in order): `~/.config/winapps/winapps.conf` or `~/.winapps`

Key variables: `RDP_IP`, `RDP_USER`, `RDP_PASS`, `RDP_DOMAIN`, `RDP_FLAGS`, `MULTIMON`, `DEBUG`, `RDP_SCALE`

If `RDP_IP` is unset, the script auto-detects a KVM VM named `RDPWindows` via `virsh` and DHCP leases.

## Runtime Dependencies

### Linux
- `bash` >= 4.0
- `xfreerdp` (FreeRDP): `sudo apt-get install freerdp2-x11`
- `virsh` (optional, for KVM auto-detection)
- User must be in `libvirt` and `kvm` groups for KVM mode

### macOS
- `bash` (ships with macOS or via Homebrew)
- Microsoft "Windows App" (free, Mac App Store) — no FreeRDP/XQuartz needed
- `RDP_IP` must be set manually (no KVM auto-detection)

## Key Files

| Purpose | Path |
|---------|------|
| Main launcher | `bin/winapps` |
| Installer | `installer.sh` |
| App configs | `apps/*/info` |
| Windows scanner | `install/ExtractPrograms.ps1` |
| KVM VM config | `kvm/RDPWindows.xml` |
| KVM setup guide | `docs/KVM.md` |
| macOS setup guide | `docs/macOS.md` |
| Homebrew formula | `Formula/winapps.rb` |

## Fork Info

This is a fork of `Fmstrat/winapps`. Remote `origin` is `dingyifei/winapps`, remote `upstream` is `Fmstrat/winapps`.
