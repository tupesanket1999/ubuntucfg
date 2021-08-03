#!/bin/sh

echo -n "Select the monitor config\n1) Horizontal\n2) Vertical\n3) Only monitor\nEnter the name of a country: "

read EXPRESSION


case $EXPRESSION in

  1)
#horizontal
xrandr --output eDP-1 --mode 1920x1080 --pos 1920x676 --rotate normal --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off
    ;;

  2)
#vertical
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1080x840 --rotate normal --output HDMI-1 --mode 1920x1080 --pos 0x0 --rotate left --output DP-1 --off
    ;;

  3)
#only monitor
xrandr --output eDP-1 --off --output HDMI-1 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off
    ;;

  *)
    echo "not corrent input"
    ;;
esac

#restart i3
i3-msg restart
