# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export PATH="$HOME/.local/bin:$PATH"

# --- productivity additions (iPad/SSH setup) ---

# bigger history — worth more when typing is slower on a touch keyboard
HISTSIZE=10000
HISTFILESIZE=20000

# fzf: fuzzy history (Ctrl-R), file search (Ctrl-T), cd (Alt-C) — much faster
# than typing full paths/commands on an iPad keyboard.
# Paths vary by distro/install method, so probe rather than hardcode:
#   Ubuntu 24.04 apt : key-bindings in /usr/share/doc/fzf/examples,
#                      completion moved to /usr/share/bash-completion/completions/fzf
#   Debian/older     : both under /usr/share/doc/fzf/examples
#   git/brew install : `fzf --bash` emits both (fzf >= 0.48)
if command -v fzf >/dev/null 2>&1; then
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    else
        for _f in /usr/share/doc/fzf/examples/key-bindings.bash \
                  /usr/share/doc/fzf/examples/completion.bash \
                  /usr/share/bash-completion/completions/fzf \
                  /opt/homebrew/opt/fzf/shell/key-bindings.bash \
                  /opt/homebrew/opt/fzf/shell/completion.bash; do
            [ -f "$_f" ] && . "$_f"
        done
        unset _f
    fi
fi

# bat is installed as `batcat` on Debian/Ubuntu due to a name clash
command -v batcat >/dev/null 2>&1 && alias bat='batcat' && alias cat='batcat --paging=never'

# fd is installed as `fdfind` on Debian/Ubuntu due to a name clash
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'

# eza (better ls) if present, else fall back to exa
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first'
    alias ll='eza -alF --group-directories-first'
    alias la='eza -A'
    alias lt='eza --tree --level=2'
elif command -v exa >/dev/null 2>&1; then
    alias ls='exa --group-directories-first'
    alias ll='exa -alF --group-directories-first'
    alias la='exa -A'
    alias lt='exa --tree --level=2'
fi

alias lg='lazygit'

# `cheat lazygit` / `cheat fzf` -- open a quick-reference cheatsheet, no
# context switch away from the terminal
cheat() {
    local sheet="$HOME/.cheatsheets/$1.md"
    if [ -z "$1" ]; then
        echo "Available cheatsheets:"
        ls "$HOME/.cheatsheets" | sed 's/\.md$//'
    elif [ -f "$sheet" ]; then
        command -v batcat >/dev/null 2>&1 && batcat --paging=always --style=plain "$sheet" || less "$sheet"
    else
        echo "No cheatsheet for '$1'. Available:"
        ls "$HOME/.cheatsheets" | sed 's/\.md$//'
    fi
}
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# quick shell/bashrc management
alias sb='source ~/.bashrc'
alias eb='nvim ~/.bashrc'

alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status -sb'
alias gd='git diff'

alias et='nvim ~/.tmux.conf'
alias ev='cd ~/.config/nvim/ && nvim init.lua'

# sdb (Solved DB) — SSM tunnel to the shared RDS instance (localhost:15432).
# After running: psql -h localhost -p 15432 -U <user> -d <client_db>
alias sdb='~/scripts/ssm-tunnel.sh'

# zoxide: `z <partial dir name>` jumps to frecent directories — saves a lot
# of typing full paths on an iPad keyboard
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# starship prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

# Machine-specific config: per-box PATH entries, host-only aliases, anything
# that shouldn't be committed. Untracked, so this repo stays identical across
# machines. Sourced before the tmux block so a box can opt out of auto-attach.
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

# Auto-attach to a persistent tmux session on login over SSH, so a dropped
# iPad connection never loses your work — reattaches to "main" if it
# exists, creates it otherwise. Skipped for non-interactive/already-tmux
# shells, for VS Code / other embedded terminals, and for dumb terminals
# (scp, rsync, some editor remote pickers) which tmux can't run in.
if command -v tmux >/dev/null 2>&1 && [ -n "${SSH_CONNECTION:-}" ] && [ -z "${TMUX:-}" ] \
   && [ -z "${VSCODE_INJECTION:-}" ] && [ -z "${NO_TMUX_AUTOATTACH:-}" ] \
   && [ "${TERM:-dumb}" != "dumb" ]; then
    # -A = attach if "main" exists, create it otherwise (atomic, no race)
    tmux new-session -A -s main
fi
