# USB Power Saving Disabled

A small Windows batch utility that disables USB power-saving flags via WMI (`MSPower_DeviceEnable`) so Windows is less likely to power down USB devices.

## What it does
- Auto-elevates to Administrator (UAC prompt if needed)
- Scans `root\wmi` → `MSPower_DeviceEnable`
- Filters entries containing `USB` in `InstanceName`
- Sets `Enable = False` where applicable
- Prints a clean summary (Changed / Already Disabled / Total)

## Why this exists
Some systems randomly power down USB devices (controllers, hubs, certain peripherals) due to power-saving behavior. Disabling these flags can reduce disconnects, stutter, or device “sleep” issues.

## How to use
1. Download the `.bat` file from **Releases**.
2. Right-click → **Run as administrator**  
   (or double-click — it will request admin automatically)
3. Read the summary and press any key to exit.

## Notes / Limitations
- This targets **WMI power entries** that match `*USB*`. It does not modify every possible device class.
- Behavior can vary by hardware, driver, and Windows version.
- If a device driver ignores these flags, it may not change behavior.

## Safety
This script only changes a power-management flag for matching WMI entries. It does **not** uninstall drivers or modify registry power plans.

That said: use at your own risk, especially on laptops where aggressive power saving is expected.

## Troubleshooting
- If it shows **Total: 0**, your system may not expose these entries through WMI.
- If PowerShell errors appear, run Windows PowerShell manually as Admin once and try again.
