# 2. Flash the Echo Show 8 (1st gen, crown)

Model **C7H6N3** only. The number is on the bottom of the device, next to the FCC ID.

## Before you start

- On the Show, open **Settings > Device Options > About**. The unlock needs **Fire OS 6.5.7.1 to 6.5.7.4**. Update into that range if it's older, then disconnect Wi-Fi so it can't pull a patched build.
- Deregister the Show from your Amazon account.
- Download `amonet-crown` v2 and the newest **Echo Show 8 (1st gen)** release of [lineageos-echo-kiosk-satellite](https://github.com/jxlarrea/lineageos-echo-kiosk-satellite/releases?q=crown).

## Step 1: Unlock with amonet

Enter fastboot:

1. Unplug power.
2. Hold **Volume Down + Volume Up + Mute** together.
3. Plug power back in and keep holding until **FASTBOOT** appears in the lower left.
4. Connect the micro-USB cable.

```sh
cd amonet-crown-v2.0.2/amonet
sudo ./fastbrick.sh
```

Expected detection:

```
Detected: CROWN - Echo Show 8 1st Generation - 2019
LK build: a5c9863-20191025_201405
Will use payload: fastbrick.img
```

> **Warning:** If it detects anything other than CROWN, stop. Otherwise type `YES`, then don't touch the cable, power or buttons until TWRP is on the screen. Interrupting this step can brick the Show.

## Step 2: Confirm recovery mode

```sh
adb devices -l
adb shell getprop ro.twrp.version
```

| Check | Expected |
| --- | --- |
| `adb devices -l` | The Show's line ends in `recovery` |
| `ro.twrp.version` | `3.7.0_9-0` |

Any other TWRP version means the unlock didn't finish. Stop and go back to the XDA thread. `scripts/check-recovery.sh show8` runs both checks.

## Step 3: Wipe and install

```sh
adb shell twrp wipe cache
adb shell twrp wipe data
adb push lineageos-echo-kiosk-satellite-2026.11.5-crown.zip /sdcard/update.zip
adb shell twrp install /sdcard/update.zip
```

> **Warning:** Wipe only cache and data. Wiping other partitions can brick the Show.

The install must end with `script succeeded: result was [1.000000]`. If it prints `assert failed` or an error, **don't reboot**. TWRP is still running and nothing is lost yet.

On success:

```sh
adb shell rm /sdcard/update.zip
adb reboot
```

> **Tip:** The upstream guide says "if it fails, stop here". The reboot is the success path. Until you run it, the Show stays in TWRP and `sys.boot_completed` comes back empty.

## Step 4: First boot

The first boot takes about 90 seconds. Tick **Always allow from this computer** on the USB debugging prompt and tap **Allow**.

```sh
adb shell getprop sys.boot_completed
adb shell echo_service time sync $(date +%s) $(timedatectl show -p Timezone --value)
adb shell "echo_service wifi connect '<ssid>' '<password>'"
adb shell echo_service wifi
adb logcat -s ks-install
```

`sys.boot_completed` prints `1` once Android is up. The Wi-Fi status prints the frequency and IP address. The install log should show:

```
ks-install: downloading .../kiosk-satellite-<version>.armeabi-v7a.apk
ks-install: installed Kiosk Satellite
ks-install: Kiosk Satellite is the device owner
ks-install: permissions granted
```

> **Tip:** The Show shares one radio between Bluetooth and 2.4 GHz Wi-Fi. If `echo_service wifi` shows 24xx MHz, join a 5 GHz SSID or run `adb shell echo_service bt off`.

Next: [Echo Dots](03-echo-dot-2nd-gen.md) or [Home Assistant](04-home-assistant.md).
