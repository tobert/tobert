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
RETVAL=2
if [ -e "$HOME/.ssh-agent" ] ; then
    . $HOME/.ssh-agent
    # see if they're still valid by trying to list keys
    ssh-add -l 2>/dev/null >/dev/null
    RETVAL=$?
fi
# returns 2 if ssh-agent isn't running or it's broken
if [ $RETVAL -eq 2 ] ; then
    # make sure it's really dead
    SSH_AGENT_PID=`ps -eo pid,user,args |awk '/tobert[[:space:]]*ssh-agent/{print $1}'`
    if [ -n "$SSH_AGENT_PID" ] ; then
        kill $SSH_AGENT_PID
        unset SSH_AGENT_PID
    fi
    # start a new agent
    ssh-agent 2>/dev/null |grep -v '^echo' > $HOME/.ssh-agent
    # read the config into this shell
    . $HOME/.ssh-agent
fi
unset RETVAL

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

if [ -z "$(which rbenv)" ] ; then
    eval "$(rbenv init -)"
fi

