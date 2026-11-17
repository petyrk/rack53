# 1. Prepare a Linux host

Use Linux. On Windows you have to install the Kindle Fire driver and Google's USB driver and hope the right one binds each time the device changes mode mid-flash. On Linux, adb, fastboot and the amonet scripts talk to the device directly once two things are fixed: ModemManager and USB permissions.

`scripts/host-prep.sh` does all of this. The manual steps follow.

## Install the tools (Debian/Ubuntu)

```sh
sudo apt install android-sdk-platform-tools python3 python3-serial unzip
```

## Stop ModemManager

ModemManager probes every new USB serial device for a modem. That breaks the exploit's serial connection and causes errors such as "Serial protocol mismatch".

```sh
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager
```

## Allow access to Amazon's USB vendor ID (1949)

Without this rule, fastboot reports "no permissions".

```sh
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="1949", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-amazon.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## Check the device is visible

With a device plugged in and in fastboot:

```sh
lsusb | grep -i 1949
```

## Make the amonet scripts executable

Unzipping can strip the execute bit. If `./fastbrick.sh` says "Permission denied", run this inside the `amonet` folder:

```sh
chmod +x *.sh
chmod +x bin/*
```

## Cable

Use a micro-USB cable that carries data. A charge-only cable gives no error. The device just never shows up.
