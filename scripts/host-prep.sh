#!/usr/bin/env bash
# Prepare a Debian/Ubuntu host for flashing Echo Show 8 (crown) and Echo Dot (biscuit).
set -euo pipefail

echo "Installing adb, fastboot, python3 and pyserial..."
sudo apt-get update
sudo apt-get install -y android-sdk-platform-tools python3 python3-serial unzip

if systemctl list-unit-files | grep -q '^ModemManager'; then
  echo "Stopping and disabling ModemManager (it grabs the exploit's serial port)..."
  sudo systemctl stop ModemManager
  sudo systemctl disable ModemManager
else
  echo "ModemManager not installed, nothing to stop."
fi

RULE='SUBSYSTEM=="usb", ATTR{idVendor}=="1949", MODE="0666", GROUP="plugdev"'
RULE_FILE=/etc/udev/rules.d/51-amazon.rules
echo "Writing udev rule for Amazon's USB vendor ID 1949 to ${RULE_FILE}..."
echo "${RULE}" | sudo tee "${RULE_FILE}" > /dev/null
sudo udevadm control --reload-rules
sudo udevadm trigger

echo
echo "Host ready. Check versions:"
adb version | head -1
fastboot --version | head -1
echo
echo "With a device in fastboot, this should list it:"
echo "  lsusb | grep -i 1949"
