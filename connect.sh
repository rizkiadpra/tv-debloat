#!/bin/sh
# usage: ./connect.sh [tv-ip] [local-port]
# Starts the loopback relay if needed, then connects adb to it.
# Why: macOS 26 Local Network Privacy blocks Homebrew adb from the LAN;
# Apple-signed /usr/bin/python3 is exempt and does the LAN hop.
cd "$(dirname "$0")"
IP=${1:-192.168.100.33}
PORT=${2:-15555}
if ! nc -z 127.0.0.1 "$PORT" 2>/dev/null; then
  nohup /usr/bin/python3 adb_relay.py "$IP" "$PORT" > "relay-$PORT.log" 2>&1 &
  sleep 2
fi
adb connect 127.0.0.1:$PORT
adb devices -l
