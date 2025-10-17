# ~/.bash_profile: executed by bash for login shells
# See bash(1) for more details

# ============================================================================
# Environment Variables
# ============================================================================

# Set reasonable umask
umask 022

# ============================================================================
# PATH Configuration
# ============================================================================

# Function to add directories to PATH without duplicates
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathprepend() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1${PATH:+":$PATH"}"
    fi
}

# Start with a clean, predictable base PATH
PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# User binaries first
pathprepend "$HOME/bin"
pathprepend "$HOME/.local/bin"

# Programming language toolchains
# Go
export GOPATH="${HOME}/go"
pathadd "$GOPATH/bin"

# Rust
pathadd "$HOME/.cargo/bin"

# Node.js (via nvm if present)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
    \. "$NVM_DIR/bash_completion"
fi

# Ruby (via rbenv if present)
if [ -d "$HOME/.rbenv/bin" ]; then
    pathadd "$HOME/.rbenv/bin"
    eval "$(rbenv init - bash 2>/dev/null)"
fi

# Perl local::lib
if [ -d "$HOME/perl5/bin" ]; then
    pathadd "$HOME/perl5/bin"
    export PERL5LIB="${HOME}/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
    export PERL_LOCAL_LIB_ROOT="${HOME}/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
    export PERL_MB_OPT="--install_base \"${HOME}/perl5\""
    export PERL_MM_OPT="INSTALL_BASE=${HOME}/perl5"
fi

# WSL2 specific paths
if grep -qi microsoft /proc/version 2>/dev/null; then
    pathadd "/mnt/c/Windows/System32"
    pathadd "/mnt/c/Windows/SysWOW64"

    # Visual Studio Build Tools (if present)
    vspath="/mnt/c/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Tools/MSVC"
    if [ -d "$vspath" ]; then
        # Find the latest version
        latest=$(ls -1 "$vspath" 2>/dev/null | sort -V | tail -n1)
        if [ -n "$latest" ]; then
            pathadd "$vspath/$latest/bin/Hostx64/x64"
        fi
    fi
    unset vspath latest
fi

export PATH

# Clean up functions
unset -f pathadd pathprepend

# ============================================================================
# Editor Configuration
# ============================================================================

# Prefer neovim > vim > vi
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    alias vim="nvim"
    alias vi="nvim"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="vim"
    alias vi="vim"
elif command -v vi >/dev/null 2>&1; then
    export EDITOR="vi"
else
    echo "Warning: No text editor found (nvim/vim/vi)" >&2
fi

export VISUAL="$EDITOR"
export GIT_EDITOR="$EDITOR"

# ============================================================================
# Terminal Configuration
# ============================================================================

# Set a reasonable terminal type
# Modern terminals generally support 256 colors
case "$TERM" in
    linux|dumb)
        # Keep minimal terminals as-is
        ;;
    screen)
        export TERM="screen-256color"
        ;;
    xterm*)
        export TERM="xterm-256color"
        ;;
esac

# ============================================================================
# SSH Agent Configuration
# ============================================================================

# Smart SSH agent handling that respects forwarded agents
# Only start a new agent if we don't have one already
ssh-add -l >/dev/null 2>&1
agent_status=$?

if [ $agent_status -eq 0 ]; then
    # Agent is working (local or forwarded), save it
    echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK ; export SSH_AUTH_SOCK" > "$HOME/.ssh-agent"
elif [ $agent_status -eq 1 ]; then
    # Agent is running but has no identities
    echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK ; export SSH_AUTH_SOCK" > "$HOME/.ssh-agent"
elif [ -f "$HOME/.ssh-agent" ]; then
    # Try loading saved agent info
    . "$HOME/.ssh-agent"
    ssh-add -l >/dev/null 2>&1
    if [ $? -eq 2 ]; then
        # Saved agent is stale, clean it up
        rm -f "$HOME/.ssh-agent"
        unset SSH_AUTH_SOCK SSH_AGENT_PID
    fi
fi

unset agent_status

# ============================================================================
# Rust Cargo Environment
# ============================================================================

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# ============================================================================
# Source .bashrc for Interactive Shells
# ============================================================================

# .bashrc handles interactive shell configuration
if [ -n "$PS1" ] && [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# ============================================================================
# Local Customizations
# ============================================================================

# Source local bash_profile additions (not tracked in dotfiles)
if [ -f ~/.bash_profile.local ]; then
    . ~/.bash_profile.local
fi
