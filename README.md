# Cursor – Linux Installer

<p align="center">
  <img src="https://cursor.com/cursor-website-proxy/assets/videos/logo/logo-loading.gif" alt="Cursor Logo" width="150">
</p>

<h1 align="center">Cursor – Linux Installer</h1>

<p align="center">
  <a href="https://github.com/crc137/cursor/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="GitHub License">
  </a>
  <a href="https://github.com/crc137/cursor/issues">
    <img src="https://img.shields.io/github/issues/crc137/cursor" alt="GitHub Issues">
  </a>
</p>

**Cursor** is an AI-powered coding assistant and modern code editor. This repository provides a simple **Linux installer** to install, update, or uninstall Cursor.

## Screenshots

| Installer Menu                                                               | After Installation                                               | Cursor Running                                                |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------- |
| ![Installer Menu](https://raw.coonlink.com/cloud/image.jpg)                  | ![After Installation](https://raw.coonlink.com/cloud/image1.jpg) | ![Program Running](https://raw.coonlink.com/cloud/image2.jpg) |
| Simple text-based menu with options to install, uninstall, or check updates. | Cursor interface after installation.                             | Cursor launched and ready to use.                             |

## Installation

1. Clone the repository:

```bash
git clone https://github.com/crc137/cursor.git
cd cursor
```

2. Make the installer executable:

```bash
chmod +x install.sh
```

3. Run the installer:

```bash
./install.sh
```

4. Follow the terminal instructions to install, update, or uninstall Cursor.

> Tip: If you encounter permission issues, prepend `sudo` to the command.

## Files and Scripts

* `install.sh` – main script for installing, uninstalling, and integrating Cursor.
* `cursor_update_check.sh` – checks for updates and automatically updates the AppImage.

## Notes

* Scripts are **Linux only**. For macOS or Windows, use the official website [cursor.com](https://cursor.com).
* Ensure the following are installed: `bash`, `chmod`, `git`.

## License

MIT © [Coonlink](https://coonlink.com)
