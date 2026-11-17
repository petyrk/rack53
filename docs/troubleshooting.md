# Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `./fastbrick.sh: Permission denied` | Unzipping dropped the execute bit | `chmod +x *.sh` and `chmod +x bin/*` in the `amonet` folder |
| fastboot shows `no permissions` | No udev rule for vendor ID 1949 | Run `scripts/host-prep.sh` |
| "Serial protocol mismatch" or the exploit never connects | ModemManager grabbed the serial port | `sudo systemctl stop ModemManager` |
| Device never appears in `lsusb` | Charge-only cable, or not in fastboot | Swap cable, re-enter fastboot |
| `ro.twrp.version` isn't `3.7.0_9-0` | Unlock incomplete or amonet 1 | Stop. Redo the unlock with amonet v2 |
| `sys.boot_completed` prints nothing | Still in TWRP, or still booting | `adb reboot` if in TWRP. Otherwise wait and check again |
| Install prints `assert failed` | Wrong image for the device | Don't reboot. Push the correct image and install again |
| Show: `echo_service wifi` says "on, not connected" | Checked before the scan finished | Wait about 15 seconds and check again |
| Show joins 2.4 GHz | Same SSID on both bands | Use a 5 GHz SSID, or `adb shell echo_service bt off` |
| Dot boot-loops | Bad slot | Unplug, hold **+**, plug in for TWRP, `bcbtool set_active` the working slot, reboot |
| Dot never prints `permissions granted` | Normal for the Dot | `Kiosk Satellite is the device owner` means it finished |

## Useful checks

```sh
adb devices -l
adb shell getprop ro.twrp.version
adb shell bcbtool get_active
adb shell getprop sys.boot_completed
adb shell echo_service status
adb shell biscuit_service status
```

`echo_service` is the Show's setup tool and `biscuit_service` is the Dot's.
