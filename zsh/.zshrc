#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set to superior editing mode
set -o vi

# keybinds
# bind -x '"\C-l":clear'
# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

export VISUAL=nvim
export EDITOR=nvim

# config
export BROWSER="safari"

# directories
export REPOS="$HOME/Code"
export GITUSER="chrisogilvie"
export DOTFILES="$REPOS/3-Personal/dotfiles"
export ONEDRIVE="$HOME/OneDrive"
# get rid of mail notifications on MacOS
unset MAILCHECK

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~

PATH="${PATH:+${PATH}:}"$SCRIPTS":"$HOME"/.local/bin:$HOME/dotnet" # appending

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~

export HISTFILE=~/.histfile
export HISTSIZE=25000
export SAVEHIST=25000
export HISTCONTROL=ignorespace

# ~~~~~~~~~~~~~~~ Functions ~~~~~~~~~~~~~~~~~~~~~~~~

# This function is stolen from rwxrob

# # clone() {
#   local repo="$1" user
#   local repo="${repo#https://github.com/}"
#   local repo="${repo#git@github.com:}"
#   if [[ $repo =~ / ]]; then
#     user="${repo%%/*}"
#   else
#     user="$GITUSER"
#     [[ -z "$user" ]] && user="$USER"
#   fi
#   local name="${repo##*/}"
#   local userd="$REPOS/github.com/$user"
#   local path="$userd/$name"
#   [[ -d "$path" ]] && cd "$path" && return
#   mkdir -p "$userd"
#   cd "$userd"
#   echo gh repo clone "$user/$name" -- --recurse-submodule
#   gh repo clone "$user/$name" -- --recurse-submodule
#   cd "$name"
# } && export -f clone
#
# ~~~~~~~~~~~~~~~ SSH ~~~~~~~~~~~~~~~~~~~~~~~~
# SSH Script from arch wiki

#if ! pgrep -u "$USER" ssh-agent >/dev/null; then
#  ssh-agent >"$XDG_RUNTIME_DIR/ssh-agent.env"
#fi
#if [[ ! "$SSH_AUTH_SOCK" ]]; then
#  source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
#fi

# Only run on Ubuntu

#if [[ $(grep -E "^(ID|NAME)=" /etc/os-release | grep -q "ubuntu")$? == 0 ]]; then
#  eval "$(ssh-agent -s)" >/dev/null
#  eval "$(fzf --bash)"
#fi

# adding keys was buggy, add them outside of the script for now
#{
#ssh-add -q ~/.ssh/id_ed25519
#ssh-add -q ~/.ssh/vanoord
#ssh-add -q ~/.ssh/delegate
#} &>/dev/null

# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~

# Moved to starship 20-03-2024 for all my prompt needs.

eval "$(starship init zsh)"

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~

alias v=nvim
# alias vim=nvim

# ranger
alias r=ranger

# use FZF for my command History
alias fh='history | fzf | awk '\''{ $1=""; print substr($0,2) }'\'''

# cd
alias ..="cd .."

# Repos

alias dot='cd $DOTFILES'
alias repos='cd $REPOS'
alias solved='cd $REPOS/1-Solved/'
alias jones='cd $REPOS/2-JonesRadiology/'
alias config='cd ~/.config/'
alias c="clear"
alias onedrive="cd \$ONEDRIVE"
alias home="cd $HOME"
alias sb="cd $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Chris\ Brain/"

# ls
alias ls='ls --color=auto'
alias ll='ls -la'
# alias la='exa -laghm@ --all --icons --git --color=always'
alias la='ls -lathr'

# finds all files recursively and sorts by last modification, ignore hidden files
alias lastmod='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

alias sv='sudoedit'
alias t='tmux'
alias tas='tmux attach-session'
alias e='exit'

# git
alias gp='git pull'
alias gs='git status'
alias lg='lazygit'

# ricing
alias et='v ~/.config/awesome/themes/powerarrow/theme-personal.lua'
alias ett='v ~/.config/awesome/themes/powerarrow-dark/theme-personal.lua'
alias er='v ~/.config/awesome/rc.lua'
alias eb='v ~/.bashrc'
alias ez='v ~/.zshrc'
alias ev='cd ~/.config/nvim/ && v init.lua'
alias sbr='source ~/.bashrc'
alias szr='source ~/.zshrc'
alias s='startx'

# vim & second brain
alias in="cd \$ZETTELKASTEN/0 Inbox/"
alias zk="cd \$ZETTELKASTEN"

# starting programmes
alias cards='python3 /opt/homebrew/lib/python3.11/site-packages/mtg_proxy_printer/'

# terraform
alias tf='terraform'
alias tp='terraform plan'

# fun
alias fishies=asciiquarium

# fzf aliases
# use fp to do a fzf search and preview the files
alias fp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
# search for a file with fzf and open it in vim
alias vf='v $(fp)'

### Install Pomo Timer ###
# complete -C pomo pomo

