#!/usr/bin/env bash
# After the image boots: set time (Show), join Wi-Fi, follow the Kiosk Satellite install.
# Usage: scripts/post-install.sh show8|dot
set -euo pipefail

DEVICE="${1:-}"
if [[ "${DEVICE}" != "show8" && "${DEVICE}" != "dot" ]]; then
  echo "Usage: $0 show8|dot" >&2
  exit 2
fi

# Quote a value for the device's shell by wrapping it in single quotes.
squote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

adb wait-for-device
if [[ "$(adb shell getprop sys.boot_completed | tr -d '\r')" != "1" ]]; then
  echo "Android has not finished booting. Wait and run this again." >&2
  exit 1
fi

if [[ "${DEVICE}" == "show8" ]]; then
  tz="$(timedatectl show -p Timezone --value)"
  echo "Setting time and time zone (${tz})..."
  adb shell echo_service time sync "$(date +%s)" "${tz}"
fi

read -r -p "Wi-Fi SSID: " ssid
read -r -s -p "Wi-Fi password: " password
echo

if [[ "${DEVICE}" == "show8" ]]; then
  adb shell "echo_service wifi connect $(squote "${ssid}") $(squote "${password}")"
else
  adb shell "biscuit_service wifi connect $(squote "${ssid}") $(squote "${password}")"
fi
unset password

echo "Waiting for an IP address (up to 60s)..."
for _ in $(seq 1 12); do
  sleep 5
  if [[ "${DEVICE}" == "show8" ]]; then
    status="$(adb shell echo_service wifi | tr -d '\r')"
    if [[ "${status}" == connected* ]]; then
      echo "${status}"
      if [[ "${status}" =~ 24[0-9][0-9]\ MHz ]]; then
        echo "NOTE: joined 2.4 GHz. Use a 5 GHz SSID or run: adb shell echo_service bt off"
      fi
      break
    fi
  else
    ip="$(adb shell ip -4 addr show wlan0 | tr -d '\r' | awk '/inet /{print $2}')"
    if [[ -n "${ip}" ]]; then
      echo "Dot address: ${ip}"
      break
    fi
  fi
done

echo
echo "Following the Kiosk Satellite install. Press Ctrl+C once you see:"
if [[ "${DEVICE}" == "show8" ]]; then
  echo "  'Kiosk Satellite is the device owner' and 'permissions granted'"
else
  echo "  'Kiosk Satellite is the device owner' (the Dot doesn't print 'permissions granted')"
fi
echo "Then finish setup at http://<device-ip>:2324"
adb logcat -s ks-install
