# USB Sleep Guard (Power Saving Disabler)

A Windows batch script that turns off USB power-saving flags exposed by WMI (`MSPower_DeviceEnable`).

## What this script changes
- Ensures the script is running with Administrator privileges (self-elevates when needed)
- Reads USB-related entries from `root\wmi` → `MSPower_DeviceEnable`
- Disables `Enable` only for entries that are currently set to `True`
- Prints a summary with counts for:
  - updated entries
  - entries already disabled
  - total USB entries found

## Typical use case
If Windows keeps putting USB devices/controllers to sleep, this can help reduce random disconnects, lag spikes, and wake delays.

## Run instructions
1. Download `USB Power Saving.bat`.
2. Launch it as Administrator (double-click is also fine; it will prompt for elevation).
3. Wait for the summary screen and close.

## Notes
- The script only affects WMI objects matching `*USB*` in `InstanceName`.
- Coverage depends on hardware vendors, drivers, and Windows build.
- Some devices may still use their own power-management behavior outside this WMI class.

## Safety
This does **not** remove drivers or edit power plans directly. It only updates matching WMI power flags.

As with any system-level setting change, test on your machine and keep a rollback plan if needed.
