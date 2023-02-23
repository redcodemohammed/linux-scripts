#! /bin/bash

# exit on error
set -e

#hdmi=$(cat /sys/class/drm/card0-HDMI-A-1/status)
#vga=$(cat /sys/class/drm/card0-VGA-1/status)
if [[ "$WAYLAND_DISPLAY" == "" ]]; then
    connected=$(xrandr | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
else
    connected=$(swaymsg -pt get_outputs | grep -E "^Output" | awk '{print $2}')
fi

#echo "initscreen.sh: hdmi $hdmi; vga $vga"

if [[ $connected =~ "LVDS-0" ]]; then
    if [[ $connected =~ "HDMI-0" ]]; then
        # hdmi only
        # NOTE: i3 fails if no active output is detected, so we have to first enable second output and then disable the first
    #    xrandr --nograb --output HDMI-0 --auto --primary
    #    xrandr --nograb --output LVDS-0 --off
        # both
        # HDMI-0 is primary, LVDS-0 is panned to be vertically aligned to the bottom
    #    xrandr --nograb --output HDMI-0 --auto --primary --output LVDS-0 --auto --left-of HDMI-0 --panning 1366x768+0+312
        xrandr --output HDMI-0 --auto --primary --output LVDS-0 --auto --left-of HDMI-0 --panning 1366x768+0+312
    #    xrandr --output HDMI-0 --auto --primary --output LVDS-0 --auto --right-of HDMI-0
    elif [[ $connected =~ "VGA-0" ]]; then
    #    xrandr --nograb --output VGA-0 --auto --output LVDS-0 --mode 1024x768 --primary
        # TODO:  look at --scale argument
        xrandr --output VGA-0 --auto --primary --output LVDS-0 --auto --below VGA-0
    else
    #    xrandr --nograb --output LVDS-0 --auto --primary --output HDMI-0 --off
    #    xrandr --output LVDS-0 --auto --primary --output HDMI-0 --off
        xrandr --output LVDS-0 --auto --primary --output HDMI-0 --off --output VGA-0 --off
    fi
elif [[ $connected =~ "eDP-1" ]]; then
    if [[ -f /proc/acpi/button/lid/LID/state ]]; then
        lid=$(cat /proc/acpi/button/lid/LID/state | awk '{print $2}')
    else
        lid="open"
    fi
    if [[ "$WAYLAND_DISPLAY" == "" ]]; then
        if [[ $connected =~ "HDMI-1" ]] && [[ "$lid" == "closed" ]]; then
            xrandr --output HDMI-1 --auto --primary --output eDP-1 --off
            echo "Xft.dpi: 96" | xrdb -merge
        elif [[ $connected =~ "HDMI-1" ]]; then
            xrandr --output HDMI-1 --auto --primary --output eDP-1 --auto --left-of HDMI-1
        else
            xrandr --output eDP-1 --auto --primary --output HDMI-1 --off
            echo "Xft.dpi: 168" | xrdb -merge   # scale=1.75
        fi
    else
        if [[ $connected =~ "HDMI-A-1" ]] && [[ "$lid" == "closed" ]]; then
            swaymsg output HDMI-A-1 enable
            swaymsg output eDP-1 disable
        elif [[ $connected =~ "HDMI-A-1" ]]; then
            swaymsg output HDMI-A-1 enable
            swaymsg output eDP-1 enable
        else
            swaymsg output eDP-1 enable
            swaymsg output HDMI-A-1 disable
        fi
    fi
else
    first=$(echo $connected | cut -f1 -d' ')
    xrandr --output ${first} --auto --primary
fi
