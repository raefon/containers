# KDLHost terminal

The web terminal uses ttyd and tmux. Mouse mode is enabled by default so a mouse
wheel or trackpad scrolls tmux history. Scroll back to the bottom or press `q` to
leave copy mode and return to normal input. For keyboard scrolling, press
`Ctrl+B`, then `[`, and use Page Up or the arrow keys.

New panes keep up to 20,000 history lines. Existing panes retain the history limit
they were created with; increasing the default does not restore discarded output.

Settings persist in `/config/kdlhost-term/.tmux.conf.local`. Startup migrates only
the old stock commented mouse/history settings and preserves explicit custom
overrides. To disable mouse handling, set `set -g mouse off` in that file and
reload the tmux configuration. Current sessions can enable scrolling immediately
with `tmux set -g mouse on`.
