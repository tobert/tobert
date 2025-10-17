# ~/.bashrc: executed by bash for non-login shells
# See bash(1) for more details

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================================================
# Shell Options
# ============================================================================

# Append to history file, don't overwrite it
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Enable recursive globbing with **
shopt -s globstar 2>/dev/null

# Correct minor spelling errors in cd commands
shopt -s cdspell 2>/dev/null

# Case-insensitive globbing
shopt -s nocaseglob 2>/dev/null

# ============================================================================
# History Configuration
# ============================================================================

# Larger history (default is 500/500)
HISTSIZE=10000
HISTFILESIZE=20000

# Don't record duplicate commands or commands starting with space
HISTCONTROL=ignoreboth:erasedups

# Ignore common commands
HISTIGNORE='ls:ll:la:cd:pwd:bg:fg:history:clear'

# Add timestamps to history
HISTTIMEFORMAT='%F %T '

# ============================================================================
# Prompt Configuration (Tokyo Matrix Theme)
# ============================================================================

# Detect if we're in a chroot
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Tokyo Matrix theme colors
# Matrix green: \033[38;5;120m
# Bright cyan: \033[38;5;87m
# Red for root: \033[01;31m
# Reset: \033[00m

hostname=$(hostname -s)
if [[ ${EUID} == 0 ]]; then
    # Root stays red for safety
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@'"${hostname}"'\[\033[38;5;87m\] \w \$\[\033[00m\] '
else
    # Tokyo Matrix: green user@host, cyan path
    PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;120m\]\u@'"${hostname}"'\[\033[38;5;87m\] \w \$\[\033[00m\] '
fi

# Set terminal title for xterm-compatible terminals
case "$TERM" in
xterm*|rxvt*|screen*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# ============================================================================
# Colors and Directory Listings
# ============================================================================

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ============================================================================
# Completion
# ============================================================================

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ============================================================================
# Aliases
# ============================================================================

# Load aliases from separate file
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ============================================================================
# Less Configuration
# ============================================================================

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Less colors for man pages (Tokyo Matrix theme)
export LESS_TERMCAP_mb=$'\033[1;32m'     # begin blinking - green
export LESS_TERMCAP_md=$'\033[1;36m'     # begin bold - cyan
export LESS_TERMCAP_me=$'\033[0m'        # end mode
export LESS_TERMCAP_se=$'\033[0m'        # end standout-mode
export LESS_TERMCAP_so=$'\033[38;5;120m' # begin standout-mode (matrix green)
export LESS_TERMCAP_ue=$'\033[0m'        # end underline
export LESS_TERMCAP_us=$'\033[4;36m'     # begin underline - cyan

# ============================================================================
# Local Customizations
# ============================================================================

# Source local bashrc additions (not tracked in dotfiles)
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi
