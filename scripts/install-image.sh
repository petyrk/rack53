#!/usr/bin/env bash
# Wipe and install a lineageos-echo-kiosk-satellite image from TWRP.
#   show8: wipe cache + data, install once, reboot
#   dot:   wipe cache + data, install to slot A, boot, then install to slot B without wiping
# Usage: scripts/install-image.sh show8|dot <image.zip>
set -euo pipefail

DEVICE="${1:-}"
IMAGE="${2:-}"
EXPECTED_TWRP="3.7.0_9-0"
BOOT_TIMEOUT=300

usage() {
  echo "Usage: $0 show8|dot <image.zip>" >&2
  exit 2
}

[[ "${DEVICE}" == "show8" || "${DEVICE}" == "dot" ]] || usage
[[ -f "${IMAGE}" ]] || { echo "Image not found: ${IMAGE}" >&2; usage; }

case "${DEVICE}" in
  show8) [[ "${IMAGE}" == *crown* ]] || { echo "Refusing: ${IMAGE} is not a crown (Echo Show 8) image." >&2; exit 1; } ;;
  dot)   [[ "${IMAGE}" == *biscuit* ]] || { echo "Refusing: ${IMAGE} is not a biscuit (Echo Dot) image." >&2; exit 1; } ;;
esac

confirm() {
  local answer
  read -r -p "$1 Type YES to continue: " answer
  [[ "${answer}" == "YES" ]] || { echo "Stopped."; exit 1; }
}

require_recovery() {
  adb wait-for-recovery
  if ! adb devices -l | grep -q ' recovery '; then
    echo "Device is not in recovery. Stopping." >&2
    exit 1
  fi
  local v
  v="$(adb shell getprop ro.twrp.version | tr -d '\r')"
  if [[ "${v}" != "${EXPECTED_TWRP}" ]]; then
    echo "TWRP is '${v}', expected ${EXPECTED_TWRP}. Stopping." >&2
    exit 1
  fi
}

active_slot() {
  adb shell bcbtool get_active | tr -d '\r'
}

twrp_install() {
  local out
  echo "Installing /sdcard/update.zip..."
  out="$(adb shell twrp install /sdcard/update.zip 2>&1 | tr -d '\r')"
  echo "${out}"
  if ! grep -q 'script succeeded' <<< "${out}"; then
    echo
    echo "Install did NOT report 'script succeeded'. Do not reboot." >&2
    echo "TWRP is still running. Fix the problem and install again." >&2
    return 1
  fi
  echo "Install succeeded."
}

wait_for_boot() {
  echo "Waiting for Android to finish booting (up to ${BOOT_TIMEOUT}s)..."
  [[ "${DEVICE}" == "show8" ]] && echo "On the Show: tick 'Always allow from this computer' and tap Allow when asked."
  adb wait-for-device
  local waited=0
  until [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 5
    waited=$((waited + 5))
    if (( waited >= BOOT_TIMEOUT )); then
      echo "Timed out waiting for boot. Check the device." >&2
      exit 1
    fi
  done
  echo "Booted (sys.boot_completed = 1)."
}

echo "== Checking recovery =="
require_recovery
adb devices -l

if [[ "${DEVICE}" == "dot" ]]; then
  slot="$(active_slot)"
  if [[ "${slot}" != "a" ]]; then
    echo "Active slot is '${slot}'. The first install must go to slot A." >&2
    echo "Run: adb shell bcbtool set_active a" >&2
    echo "Then: adb reboot recovery" >&2
    exit 1
  fi
  echo "Active slot: a"
fi

confirm "This wipes cache and data on the ${DEVICE} and installs $(basename "${IMAGE}")."

echo "== Wiping cache and data (only these two) =="
adb shell twrp wipe cache
adb shell twrp wipe data

echo "== Pushing image =="
adb push "${IMAGE}" /sdcard/update.zip

twrp_install || exit 1

if [[ "${DEVICE}" == "show8" ]]; then
  adb shell rm /sdcard/update.zip
  adb reboot
  wait_for_boot
  echo "Done. Next: scripts/post-install.sh show8"
  exit 0
fi

# Dot: boot slot A once, then install slot B.
adb reboot
wait_for_boot

echo "== Switching to slot B =="
adb reboot recovery
require_recovery
adb shell bcbtool set_active b
adb reboot recovery
require_recovery
slot="$(active_slot)"
if [[ "${slot}" != "b" ]]; then
  echo "Active slot is '${slot}', expected b. Stopping." >&2
  exit 1
fi
echo "Active slot: b"

echo "== Installing to slot B (no data wipe) =="
if ! twrp_install; then
  echo "Reverting to slot A." >&2
  adb shell bcbtool set_active a
  exit 1
fi

adb shell rm /sdcard/update.zip
adb reboot
wait_for_boot
echo "Done. Both slots hold the image. Next: scripts/post-install.sh dot"
