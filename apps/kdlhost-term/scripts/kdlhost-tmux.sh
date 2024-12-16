#!/bin/bash

tmux -f /app/kdlhost-term/restricted.tmux.conf new-session -A -s kdlhost-term 'fish' \; \
    split-window -v -p 33 'supercronic -inotify /config/kdlhost-term/crontab' \; \
    select-pane -t 0 \; \
    attach-session \;