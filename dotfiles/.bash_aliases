# ~/.bash_aliases: Bash alias definitions
# Sourced by .bashrc

# ============================================================================
# File Operations
# ============================================================================

# Enhanced ls commands with colors
alias ls='ls --color=auto'
alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias lt='ls -alFht --color=auto'  # Sort by time, newest first

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Safety features
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# ============================================================================
# Grep and Search
# ============================================================================

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Commonly used grep patterns
alias grepi='grep -i'
alias grepr='grep -r'
alias grepv='grep -v'

# ============================================================================
# Disk Usage
# ============================================================================

alias df='df -h'
alias du='du -h'
alias du1='du -h -d 1'
alias dus='du -sh'

# ============================================================================
# Process Management
# ============================================================================

alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psme='ps aux | grep $USER'

# ============================================================================
# Network
# ============================================================================

alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'

# Modern alternatives (if available)
if command -v ip >/dev/null 2>&1; then
    alias ipa='ip -c addr'
    alias ipr='ip -c route'
fi

# ============================================================================
# Git Shortcuts
# ============================================================================

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --decorate --graph'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gf='git fetch'
alias gpl='git pull'

# ============================================================================
# System Information
# ============================================================================

alias meminfo='free -h'
alias cpuinfo='lscpu'
alias diskinfo='lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE'

# ============================================================================
# Safety Aliases for Common Mistakes
# ============================================================================

# Prevent accidental overwrites
alias wget='wget -c'  # Continue downloads by default

# ============================================================================
# Utility Shortcuts
# ============================================================================

# Make commands more human-friendly
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias timer='echo "Timer started. Press Ctrl+D to stop." && date && time cat && date'

# Quick directory listing with tree (if available)
if command -v tree >/dev/null 2>&1; then
    alias tree1='tree -L 1'
    alias tree2='tree -L 2'
    alias tree3='tree -L 3'
fi

# ============================================================================
# Development Tools
# ============================================================================

# Python
alias py='python3'
alias pip='python3 -m pip'
alias venv='python3 -m venv'

# Docker shortcuts (if docker is available)
if command -v docker >/dev/null 2>&1; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlogs='docker logs -f'
fi

# Kubernetes shortcuts (if kubectl is available)
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgd='kubectl get deployments'
    alias kdesc='kubectl describe'
    alias klogs='kubectl logs -f'
fi

# ============================================================================
# Editor Shortcuts
# ============================================================================

# Quick config file edits
alias vimrc='$EDITOR ~/.vimrc'
alias bashrc='$EDITOR ~/.bashrc'
alias bashal='$EDITOR ~/.bash_aliases'
alias bashprof='$EDITOR ~/.bash_profile'

# ============================================================================
# Systemd (if available)
# ============================================================================

if command -v systemctl >/dev/null 2>&1; then
    alias sctl='systemctl'
    alias sctlu='systemctl --user'
    alias jctl='journalctl'
    alias jctlf='journalctl -f'
fi

# ============================================================================
# Platform-Specific Aliases
# ============================================================================

# Arch Linux specific
if [ -f /etc/arch-release ]; then
    alias pacup='sudo pacman -Syu'
    alias pacin='sudo pacman -S'
    alias pacrm='sudo pacman -Rns'
    alias pacsr='pacman -Ss'
fi

# Ubuntu/Debian specific
if [ -f /etc/debian_version ]; then
    alias aptup='sudo apt update && sudo apt upgrade'
    alias aptin='sudo apt install'
    alias aptrm='sudo apt remove'
    alias aptsr='apt search'
    alias aptclean='sudo apt autoremove && sudo apt autoclean'
fi

# ============================================================================
# Fun Stuff
# ============================================================================

# Weather (requires curl)
alias weather='curl wttr.in'
alias moon='curl wttr.in/Moon'

# Generate random password
alias randpw='openssl rand -base64 20'

# ============================================================================
# Reload Bash Configuration
# ============================================================================

alias reload='source ~/.bash_profile && source ~/.bashrc && echo "Bash config reloaded!"'
