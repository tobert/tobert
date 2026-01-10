#!/bin/bash
# =============================================================================
# Rainbow PS1 - Half as cool as the Claude statusline 🌈
# =============================================================================
#
# SETUP: Add to ~/.bashrc:
#   source ~/src/tobert/bin/rainbow-ps1.bash
#
# REQUIRES: Nerdfonts, 256-color terminal
# =============================================================================

# Rainbow palette (256-color)
__ps1_rainbow=(196 208 226 46 51 69 201 129)

# Braille wave for separator
__ps1_braille=('⠀' '⡀' '⠄' '⠂' '⠁' '⠈' '⠐' '⠠')

__ps1_fg() { printf '\[\e[38;5;%sm\]' "$1"; }
__ps1_reset() { printf '\[\e[0m\]'; }
__ps1_dim() { printf '\[\e[2m\]'; }

__ps1_rainbow_text() {
    local text="$1"
    local offset="${2:-0}"
    local i=0
    local result=""
    local colors=("${__ps1_rainbow[@]}")

    for ((j=0; j<${#text}; j++)); do
        char="${text:$j:1}"
        if [[ "$char" != " " ]]; then
            color_idx=$(( (i + offset) % ${#colors[@]} ))
            result+="$(__ps1_fg "${colors[$color_idx]}")${char}"
            ((i++))
        else
            result+=" "
        fi
    done
    result+="$(__ps1_reset)"
    printf '%s' "$result"
}

__ps1_git_info() {
    local branch status_chars=""

    # Get branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return

    # Check status
    git diff --cached --quiet 2>/dev/null || status_chars+="$(__ps1_fg 46)+$(__ps1_reset)"
    git diff --quiet 2>/dev/null || status_chars+="$(__ps1_fg 226)!$(__ps1_reset)"
    [[ -n $(git ls-files --others --exclude-standard 2>/dev/null | head -1) ]] && \
        status_chars+="$(__ps1_fg 51)?$(__ps1_reset)"

    # Powerline branch icon (U+E0A0)
    local branch_icon=$'\ue0a0'
    printf ' %s%s%s %s%s%s' \
        "$(__ps1_fg 201)" "$branch_icon" "$(__ps1_reset)" \
        "$(__ps1_fg 129)" "$branch" "$(__ps1_reset)"
    [[ -n "$status_chars" ]] && printf ' %s' "$status_chars"
}

__ps1_braille_sep() {
    local width="${1:-3}"
    local offset=$(( $(date +%s) % ${#__ps1_braille[@]} ))
    local result=""

    for ((i=0; i<width; i++)); do
        local phase=$(( (i + offset) % ${#__ps1_braille[@]} ))
        local char="${__ps1_braille[$phase]}"
        local color_idx=$(( (i + offset) % ${#__ps1_rainbow[@]} ))
        if [[ "$char" != "⠀" ]]; then
            result+="$(__ps1_fg "${__ps1_rainbow[$color_idx]}")${char}$(__ps1_reset)"
        else
            result+=" "
        fi
    done
    printf '%s' "$result"
}

__ps1_build() {
    local exit_code=$?
    local offset=$(( $(date +%s) % ${#__ps1_rainbow[@]} ))

    # Rainbow username
    local user_part
    user_part=$(__ps1_rainbow_text "$USER" "$offset")

    # Colored host and path
    local host_part="$(__ps1_dim)@$(__ps1_reset)$(__ps1_fg 51)\h$(__ps1_reset)"
    local path_part="$(__ps1_dim):$(__ps1_reset)$(__ps1_fg 69)\w$(__ps1_reset)"

    # Git info
    local git_part
    git_part=$(__ps1_git_info)

    # Braille separator
    local sep
    sep=$(__ps1_braille_sep 5)

    # Exit code indicator
    local prompt_char
    if [[ $exit_code -eq 0 ]]; then
        prompt_char="$(__ps1_fg 46)❯$(__ps1_reset)"
    else
        prompt_char="$(__ps1_fg 196)❯$(__ps1_reset)"
    fi

    # Build prompt
    PS1="${user_part}${host_part}${path_part}${git_part} ${sep} ${prompt_char} "
}

PROMPT_COMMAND=__ps1_build
