#!/bin/sh

# turn off wifi so only the dock NIC is used
# nmcli radio wifi off

# Scaling settings
gsettings set org.gnome.desktop.interface scaling-factor 1
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <1>}]"

# Work Dock setup with 2 external monitors
xrandr --output eDP-1 --mode 1920x1080 --output DP-2-2 --mode 1920x1200 --right-of eDP-1 --output DP-1-2 --mode 1920x1200 --right-of DP-2-2

# set screen brightness to 100%
gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 100>"

# Chrome needs to be restarted to detect new scaling settings
/usr/bin/pkill --oldest --signal TERM -f chrome
sleep 8 
google-chrome &
