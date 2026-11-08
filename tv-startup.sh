#!/bin/bash
set -u

TV_IP="192.168.0.101"
TV_MAC="10:38:1f:f9:56:9d"
TV="${TV_IP}:5555"
ADB="/usr/bin/adb"
WOL="/usr/bin/wakeonlan"

echo "Waiting for DietPi Wi-Fi..."
until ip -4 addr show wlan0 | grep -q 'inet 192.168.0.103/'; do
    sleep 2
done

echo "Starting ADB server..."
"$ADB" start-server

echo "Sending Wake-on-LAN..."
"$WOL" -i 192.168.0.255 "$TV_MAC" || true

echo "Waiting for TV..."
DEADLINE=$((SECONDS + 300))
NEXT_WOL=$((SECONDS + 15))
CONNECTED=0

while (( SECONDS < DEADLINE )); do
    "$ADB" connect "$TV" >/dev/null 2>&1 || true

    if [[ "$("$ADB" -s "$TV" get-state 2>/dev/null || true)" == "device" ]] &&
       "$ADB" -s "$TV" shell echo TV_READY >/dev/null 2>&1; then
        CONNECTED=1
        break
    fi

    if (( SECONDS >= NEXT_WOL )); then
        echo "Resending Wake-on-LAN..."
        "$WOL" -i 192.168.0.255 "$TV_MAC" || true
        NEXT_WOL=$((SECONDS + 15))
    fi

    sleep 2
done

if (( CONNECTED == 0 )); then
    echo "ERROR: TV did not become available."
    exit 1
fi

echo "Checking TV display state..."
POWER_INFO=$("$ADB" -s "$TV" shell dumpsys power 2>/dev/null || true)

if grep -q 'Display Power: state=OFF' <<< "$POWER_INFO" ||
   grep -q 'mWakefulness=Asleep' <<< "$POWER_INFO"; then
    echo "Waking TV display..."
    "$ADB" -s "$TV" shell input keyevent KEYCODE_POWER || exit 1
    sleep 3
else
    echo "TV display is already awake."
fi

echo "Opening HOME..."
"$ADB" -s "$TV" shell input keyevent KEYCODE_HOME || exit 1
sleep 2

echo "Launching Nova..."
"$ADB" -s "$TV" shell monkey -p org.courville.nova 1 || exit 1

echo "Nova launch command sent successfully."
