#!/bin/sh

# My main undock script except poweroff instead of restarting Chrome
#   useful pretty much any time I poweroff at the office
#   so when I get home the scaling is correct

# set scaling
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <2>}]"
gsettings set org.gnome.desktop.interface scaling-factor 2

## It would be awesome to be able to use this because a scale factor of 2
## is a bit too big, unfortunately there is a bug and I cannot access 
## the right and bottom of the screen as noted on the Arch Wiki under HiDPI
## Bug: https://bugs.freedesktop.org/show_bug.cgi?id=39949
#xrandr --output eDP-1 --scale 1.35x1.35 --fb 4320x2430

# use only the laptop display, set resolution automatically
xrandr --output eDP-1 --auto

# set screen brightness to 50%
gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 50>"

# poweroff the system
poweroff
