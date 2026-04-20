#!/bin/bash
set -euo pipefail
###############################################################################
# xfce4-terminal.sh
#
# Applies xfce4-terminal settings via xfconf-query. On systems where xfconfd is
# running, these values take precedence over terminalrc, so the terminalrc file
# alone is not enough to set defaults like font size and window geometry.
#
# Called from installDotfiles.sh during the terminal install step.
###############################################################################

if ! command -v xfconf-query &>/dev/null; then
  echo "xfconf-query not found, skipping xfce4-terminal xfconf setup"
  exit 0
fi

xfconf-query -c xfce4-terminal -p /font-name --create -t string -s "Cascadia Mono Bold 16"
xfconf-query -c xfce4-terminal -p /misc-default-geometry --create -t string -s "150x75"
