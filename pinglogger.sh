#!/bin/bash
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin

log_file="/Users/ryandolan/pinglog.txt"

# Add headers if file doesn't exist or is empty
if [ ! -s "$log_file" ]; then
  printf "Timestamp\tLocation\tInterface\tAvgPing(ms)\tDownload(Mbps)\tUpload(Mbps)\tPublicIP\tSSID\n" > "$log_file"
fi

# Exit if no internet connection
if ! /sbin/ping -q -c 1 -W 2 8.8.8.8 >/dev/null; then
  exit 0
fi

# Timestamp
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Ping test
ping_output=$(/sbin/ping -c 20 8.8.8.8)
avg_latency=$(echo "$ping_output" | grep 'min/avg/max' | awk -F'/' '{print $5}')

# Speed test
speedtest_output=$(/opt/homebrew/bin/speedtest --simple --timeout 15 2>/dev/null)
if [[ "$speedtest_output" == *"Download:"* ]]; then
  download_speed=$(echo "$speedtest_output" | grep 'Download:' | awk '{print $2}')
  upload_speed=$(echo "$speedtest_output" | grep 'Upload:' | awk '{print $2}')
else
  download_speed="Unavailable"
  upload_speed="Unavailable"
fi

# Get Wi-Fi interface name
wifi_device=$(/usr/sbin/networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
wifi_name="$wifi_device"

# Get SSID using wdutil (more reliable than airport)
actual_ssid=$(sudo /usr/bin/wdutil info 2>/dev/null | awk -F': ' '/^\s*SSID/ {print $2}' | sed 's/^[[:space:]]*//')

# Fallback to BSSID if SSID is missing
if [[ -z "$actual_ssid" ]]; then
  actual_ssid=$(sudo /usr/bin/wdutil info 2>/dev/null | awk -F': ' '/^\s*BSSID/ {print $2}' | sed 's/^[[:space:]]*//')
fi

# Final fallback
[[ -z "$actual_ssid" ]] && actual_ssid="Unknown"

# Get location info
geo_json=$(/usr/bin/curl -s --max-time 5 ipinfo.io/json)
city=$(echo "$geo_json" | /opt/homebrew/bin/jq -r '.city // "Unknown"')
region=$(echo "$geo_json" | /opt/homebrew/bin/jq -r '.region // "Unknown"')
country=$(echo "$geo_json" | /opt/homebrew/bin/jq -r '.country // "Unknown"')
location="${city}, ${region}, ${country}"

# Get public IP
public_ip=$(/usr/bin/dig +short myip.opendns.com @resolver1.opendns.com)

# Log results (append)
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
  "$timestamp" "$location" "$wifi_name" "$avg_latency" "$download_speed" "$upload_speed" "$public_ip" "$actual_ssid" \
  >> "$log_file"