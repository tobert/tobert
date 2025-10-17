# ~/.bash_logout: executed by bash when login shell exits

# Clear the screen for security when leaving the console
if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

# Clear terminal
clear
