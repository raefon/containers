#!/bin/bash

tmux -f /app/kdlhost-term/restricted.tmux.conf new-session -A -s kdlhost-term 'supercronic -inotify /config/kdlhost-term/crontab' \; \
    split-window -hv 'fish' \;