#!/bin/bash
# shellcheck disable=SC2317

set -u

# parameters
konsole=org.kde.konsole-2913641
session=2
SLEEP_LONG_READ="3"
SLEEP_SHORT_READ="2"
SLEEP_TRANSITION="0.4"
SLEEP_COMMAND_BEFORE="0.4"
SLEEP_COMMAND_AFTER="0.65"
SLEEP_MICROPAUSE="0.25"
SLEEP_TYPESPEED="0.10"

qtype() {
	qdbus "$konsole" "/Sessions/$session" sendText "$1"
}

qrun() {
	qdbus "$konsole" "/Sessions/$session" runCommand "$1"
}

qctrlb() {
	qdbus "$konsole" "/Sessions/$session" sendText $'\002'
}

qctrlc() {
	qdbus "$konsole" "/Sessions/$session" sendText $'\003'
}


qtype_slow() {
	echo -n "$1" \
		| sed 's/\(.\)/\1\n/g' \
		| while IFS="" read -r X ; do qtype "$X" ; sleep "$SLEEP_TYPESPEED" ; done
}

tmux_key() {
	qctrlb
	sleep 0.5
	qtype "$1"
}

qtype_arrow_up() {
	qtype $'\033'
	qtype "[A"
}

qtype_arrow_down() {
	qtype $'\033'
	qtype "[B"
}

qtype_arrow_left() {
	qtype $'\033'
	qtype "[D"
}

qtype_arrow_right() {
	qtype $'\033'
	qtype "[C"
}

## cleanup

qctrlc
tmux_key "d"
qctrlc

qrun "clear"
sleep "$SLEEP_MICROPAUSE"
qrun "cd ~/src/mfm"
sleep "$SLEEP_MICROPAUSE"
qrun "cp doc/demo.mfm.yml ~/.config/mfm.yml"
sleep "$SLEEP_MICROPAUSE"
qrun "rm -f output.rec"
sleep "$SLEEP_MICROPAUSE"
qrun "tmux kill-session -t demo"
sleep "$SLEEP_MICROPAUSE"
qrun "mkdir -p /home/vagrant/mnt"
sleep "$SLEEP_MICROPAUSE"
qrun "fusermount -u \"/home/vagrant/mnt/Public - Remote Debian Repository\""
sleep "$SLEEP_MICROPAUSE"
qrun "rm -fr \"/home/vagrant/mnt/Public - Remote Debian Repository\""
sleep "$SLEEP_MICROPAUSE"
qrun "# cleanup done"
sleep "$SLEEP_LONG_READ"

## reset demo environment
qrun "tmux new -s demo"
sleep "$SLEEP_MICROPAUSE"
tmux_key "c"
qrun "cd ~/src/mfm"
sleep "$SLEEP_MICROPAUSE"
qrun "mdp --noslidenum doc/SCRIPT.md"
sleep "$SLEEP_MICROPAUSE"

tmux_key "c"
qrun "export PATH=\$PATH:~/src/mfm/bin"
sleep "$SLEEP_MICROPAUSE"
qrun "export FZF_DEFAULT_OPTS=\"--height 40% --layout=reverse --border\""
sleep "$SLEEP_MICROPAUSE"
qrun "alias cat=\"batcat -p\""
sleep "$SLEEP_MICROPAUSE"
qrun "cd ~/src/mfm"
sleep "$SLEEP_MICROPAUSE"
qrun "clear"
sleep "$SLEEP_MICROPAUSE"

tmux_key "1"
tmux_key ":"
qrun "set -g status off"
sleep "$SLEEP_MICROPAUSE"

tmux_key "d"

## record
qrun "asciinema rec --cols 80 --rows 24 -c 'tmux attach' output.rec"

# slide 1 (title)
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# slide 2 (config file)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# cmd 2 (show config file)
qtype " "
sleep "$SLEEP_TRANSITION"

tmux_key "2"
qtype_slow "cat "
sleep "$SLEEP_MICROPAUSE"
qtype_slow "~/.config"
sleep "$SLEEP_MICROPAUSE"
qtype_slow "/mfm.yml"
sleep "$SLEEP_MICROPAUSE"
qrun ""
sleep "$SLEEP_LONG_READ" # double
sleep "$SLEEP_LONG_READ"
tmux_key "1"

# slide 3 (config options 1)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# slide 4 (config options 2)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# slide 5 (preparation - mnt)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# demo 5 (show mnt)
qtype " "
sleep "$SLEEP_TRANSITION"

tmux_key "2"
qtype_slow "cd "
sleep "$SLEEP_MICROPAUSE"
qtype_slow "~/mnt"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"

qtype_slow "ls"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_LONG_READ"
tmux_key "1"

# slide 6 (preparation - empty mnt!)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# slide 7 (usage - run)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# demo 7 (run mfm)
qtype " "
sleep "$SLEEP_TRANSITION"

tmux_key "2"
qtype_slow "m"
sleep "$SLEEP_MICROPAUSE"
qtype_slow "f"
sleep "$SLEEP_MICROPAUSE"
qtype_slow "m"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_SHORT_READ"

qtype_arrow_down
sleep "$SLEEP_MICROPAUSE"
qtype_arrow_down
sleep "$SLEEP_MICROPAUSE"
qtype_arrow_up
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_LONG_READ"

tmux_key "1"

# slide 8 (usage - what?)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# demo 8 (usage - what : show mnt)
tmux_key "2"

qtype_slow "ls"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_SHORT_READ"

qtype_slow "cd \"Pub"
sleep "$SLEEP_MICROPAUSE"
qtype "lic - Remote Debian Repository\""
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"

qtype_slow "ls"
sleep "$SLEEP_MICROPAUSE"
qtype $'\015'
sleep "$SLEEP_SHORT_READ"

qtype_slow "cd pool"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"

qtype_slow "ls"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_SHORT_READ"

qtype_slow "cd main"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"

qtype_slow "ls"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_LONG_READ"

tmux_key "1"

# slide 9 (usage - explanation)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# slide 10 (usage - prepare for detach)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# demo 10 (run mfm for detach)
qtype " "
sleep "$SLEEP_TRANSITION"

tmux_key "2"

qtype_slow "cd ~/mnt/"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"

qtype_slow "m"
sleep "$SLEEP_MICROPAUSE"
qtype_slow "f"
sleep "$SLEEP_MICROPAUSE"
qtype_slow "m"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_SHORT_READ"

qtype_arrow_down
sleep "$SLEEP_MICROPAUSE"
qtype_arrow_down
sleep "$SLEEP_MICROPAUSE"
qtype_arrow_up
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_LONG_READ"

qtype_slow "ls"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_SHORT_READ"

qtype_slow "cd \"Pub"
sleep "$SLEEP_MICROPAUSE"
qtype "lic - Remote Debian Repository\""
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_SHORT_READ"

qtype_slow "ls"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_SHORT_READ"

qtype_slow "ls -la"
sleep "$SLEEP_COMMAND_BEFORE"
sleep "$SLEEP_COMMAND_BEFORE"
qtype $'\015'
sleep "$SLEEP_COMMAND_AFTER"
sleep "$SLEEP_LONG_READ"

tmux_key "1"

# slide 11 (usage - detached)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"


# slide 12 (conclusion)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# slide 13 (conclusion)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# slide 14 (conclusion)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# slide 15 (conclusion)
qtype " "
sleep "$SLEEP_TRANSITION"
sleep "$SLEEP_LONG_READ"

# detach and clean
tmux_key "d"

qrun "tmux kill-session -t demo"
qrun "termtosvg render output.rec output.svg"

qrun "# success!"

exit 0

