# NetCheck Übersicht Widget

Monitors network health and shows:
- Ping (ms)
- Download / Upload (Mbps)
- Public IP
- Wi-Fi SSID
- Local timestamp

## Install
1) Place this folder in: `~/Library/Application Support/Übersicht/widgets/`
2) Make scripts executable: `chmod +x *.sh`
3) Widget command should point to your output script:
   `command: "/bin/bash -lc '/Users/ryandolan/ping_widget_output.sh'"`

## Notes
- SSID on newer macOS may require: