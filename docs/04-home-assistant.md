# 4. Add the fleet to Home Assistant

## Kiosk Satellite setup

Open `http://<device-ip>:2324` for each device and complete the wizard:

1. An admin password for the remote admin page.
2. The Home Assistant URL and an access token. Create a dedicated Home Assistant user for the fleet instead of using your admin token.
3. A wake word.
4. On the Show only: the dashboard to display.

## Add the devices

In Home Assistant, go to **Settings > Devices & services**. Each device appears as discovered:

| Device | Discovered name |
| --- | --- |
| Echo Show 8 | `echo-show-8-ks-` + last three characters of the serial |
| Echo Dot | `echo-dot-ks-` + last three characters of the serial |

Click **Configure** on each. Every device gets an Assist satellite, volume and device controls, and a **Firmware** update entity. Future image updates install from that entity.

With several devices hearing the same wake word, Kiosk Satellite's wake word arbitration makes the closest one answer.

## Music with Spotify (Music Assistant)

Requires Spotify Premium.

1. Install the **Music Assistant** add-on and integration. In Music Assistant, add **Spotify** under **Settings > Providers**.
2. On each device, in Kiosk Satellite: **Settings > Media Player > Sendspin Player**:
   - Enable Sendspin player: on
   - Server: `<music-assistant-host>:8927`
3. Optional: add Music Assistant's **Spotify Connect** plugin for each device's player. The devices then appear in the Spotify app's device list.

## Now Playing on the Show

In Kiosk Satellite on the Show, under **Settings > Media Player**:

- **Player source:** This device
- **Now Playing:** on instead of the screensaver, and launch when music starts
- **Floating Player:** optional compact card over the dashboard

If Now Playing shows "Unknown track" with no art, the player source points at a different player from the one playing.

## Volume

Upstream recommends the Show's master volume at 50% with Kiosk Satellite's media and assistant volumes at 100%. Above 50%, music drowns out the wake word.

On the Dot, speaker gain is set with `adb shell setprop persist.biscuit.spk_gain_db 3` (range -6 to 29, no restart needed). Upstream found 6 dB distorted at full volume.
