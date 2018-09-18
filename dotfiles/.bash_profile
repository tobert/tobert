# tobert's .profile

umask 022

# try had to find a reasonable home directory across all OS's I use
# some of this is paranoia because of systems I've worked on in the past
# that have no $HOME by default because of (silly) local policy
if [ ! -n "$HOME" ] ; then
    HOME=$(awk -F: '/^tobert/{print $6}' < /etc/passwd)
    if [ -n "$HOME" -a -d "$HOME" ] ; then
        true
    elif [ -d /mnt/c/Users/tobert ] ; then
        HOME=/mnt/c/Users/tobert
    elif [ -d /home/tobert ] ; then
        HOME=/home/tobert
    else
        echo "Could not find an appropriate \$HOME. Using /tmp."
        HOME=/tmp
    fi

    export HOME
fi

# make $PATH more interesting - and predictable
PATH="/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
if [ -n "$HOME" -a -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$GOPATH/bin" ] ; then
    PATH="$PATH:$GOPATH/bin"
fi
export PATH

# sometimes the terminal isn't set reasonably, go with xterm-color
if [ "$TERM" != "linux" -a "$TERM" != "screen" ] ; then
  export TERM="xterm-color"
fi

# colored PS1 - I almost never use terms that can't do color
# so I just reset it manually when it's missing
hostname=$(hostname -s)
if [[ ${EUID} == 0 ]] ; then
    PS1="\\[\\033[01;31m\\]$hostname\\[\\033[01;34m\\] \\W \\$\\[\\033[00m\\] "
else
    PS1="\\[\\033[01;32m\\]\\u@$hostname\\[\\033[01;34m\\] \\w \\$\\[\\033[00m\\] "
fi

# SSH agent setup
# this also gets picked up by some of my other tools like nssh
ssh-add -l >/dev/null 2>&1
if [ $? -eq 0 ] ; then
    # if SSH_AUTH_SOCK is set when this runs it might mean I'm ssh'ing into
    # e.g. ops-shell with agent forwarding in which case I do not want to
    # start ssh-agent and overwrite that, I want to rewrite that file!
    echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK ; export SSH_AUTH_SOCK" > $HOME/.ssh-agent
elif [ -e "$HOME/.ssh-agent" ] ; then
    # no agent currently available, try loading ~/.ssh-agent
    . $HOME/.ssh-agent
    ssh-add -l >/dev/null 2>&1
    if [ $? -ne 0 ] ; then
        echo "~/.ssh-agent appears to be stale, deleting it"
        rm -f ~/.ssh-agent
        unset SSH_AUTH_SOCK
    fi
fi

# PATH was set statically above so trust it and search for nvim/vim/vi
nvim=$(which nvim)
vim=$(which vim)
vi=$(which vi)

if [ -n "$nvim" ] ; then
    export EDITOR=$nvim
    alias vim=$nvim
    alias vi=$nvim
elif [ -n "$vim" ] ; then
    export EDITOR=$vim
    alias vi=$vim
elif [ -n "$vi" ] ; then
    echo "looks like we're stuck with plain 'vi', good luck!"
    export EDITOR=$vi
else
    echo "this system is broken - no nvim, vim, or vi!!!!"
fi
export EDITOR GIT_EDITOR=$EDITOR
unset vi vim nvim

alias ls='ls --color=auto'
alias ll='ls -alp --color=auto'
alias grep='grep --colour=auto'

if [ -d "${HOME}/.rbenv" ] ; then
    export PATH="${PATH}:${HOME}/.rbenv/bin"
    eval "$(rbenv init -)"
fi

