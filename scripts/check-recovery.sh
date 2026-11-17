#!/usr/bin/env bash
# Confirm a device is in TWRP recovery and ready for the kiosk image.
# Usage: scripts/check-recovery.sh show8|dot
set -euo pipefail

DEVICE="${1:-}"
if [[ "${DEVICE}" != "show8" && "${DEVICE}" != "dot" ]]; then
  echo "Usage: $0 show8|dot" >&2
  exit 2
fi

EXPECTED_TWRP="3.7.0_9-0"
fail=0

echo "== adb devices =="
adb devices -l
if ! adb devices -l | grep -q ' recovery '; then
  echo "FAIL: no device in recovery. Run 'adb reboot recovery' or use the button combo." >&2
  exit 1
fi
echo "OK: device is in recovery"

echo
echo "== TWRP version =="
twrp_version="$(adb shell getprop ro.twrp.version | tr -d '\r')"
echo "${twrp_version}"
if [[ "${twrp_version}" == "${EXPECTED_TWRP}" ]]; then
  echo "OK: TWRP ${EXPECTED_TWRP}"
else
  echo "FAIL: expected TWRP ${EXPECTED_TWRP}. The unlock is incomplete or used amonet 1. Stop here." >&2
  fail=1
fi

if [[ "${DEVICE}" == "dot" ]]; then
  echo
  echo "== Active slot =="
  slot="$(adb shell bcbtool get_active | tr -d '\r')"
  echo "${slot}"
  if [[ "${slot}" == "a" ]]; then
    echo "OK: slot A is active, ready for the first install"
  else
    echo "NOTE: slot ${slot} is active. The first install must go to slot A:"
    echo "  adb shell bcbtool set_active a"
    echo "  adb reboot recovery"
  fi
fi

exit "${fail}"
