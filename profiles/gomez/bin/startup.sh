#!/bin/sh

xrandr --output HDMI-1 --off --output eDP-1 --primaryy --mode 1920x1080 --pos 0x0 --rotate normal
wait "$!"
sleep 5

nitrogen --restore
wait "$!"

xfce4-terminal &
