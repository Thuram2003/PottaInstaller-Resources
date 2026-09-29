# Potta Finance Installer Resources

## Quick Start

1. **Generate wizard images:**
   ```bash
   python generate_wizard_images.py
   ```

2. **Build installer:**
   ```bash
   build-installer.bat
   ```
   Or open `PottaSetup-Professional.iss` in Inno Setup and press F9.

## Files

- `PottaSetup-Professional.iss` - Main installer script
- `LICENSE.txt` - End-User License Agreement
- `README.txt` - Pre-installation information
- `generate_wizard_images.py` - Creates wizard images from app logo
- `build-installer.bat` - Automated build script

## Output

Compiled installer: `installer-output/PottaSetup_v1.3.4.5.exe`

## Requirements

- Inno Setup 6.7+
- Python 3.x + Pillow (for image generation)
- .NET 8.0 SDK (for building the app)
