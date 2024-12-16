#!/bin/bash

# Prepare a tmux entry to the already-running process, use solarized dark colors
ttyd -p 3001 -W \
 -t titleFixed='TERMINAL | KDLHOST' \
 -t 'theme={"background": "#1c1c1c", "brightGreen": "#585858", "blue": "#0087ff", "black": "#262626", "brightBlack": "#1c1c1c", "brightBlue": "#808080", "brightCyan": "#8a8a8a", "brightMagenta": "#5f5faf", "brightRed": "#d75f00", "brightWhite": "#ffffd7", "brightYellow": "#626262", "cyan": "#00afaf", "green": "#5f8700", "magenta": "#af005f", "red": "#d70000", "white": "#e4e4e4", "yellow": "#af8700"}' \
 -t drawBoldTextInBrightColors=false \
 /usr/local/bin/kdlhost-tmux.sh