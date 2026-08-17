# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Zinit Plugins
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Add in snippits
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found

# fzf keybindings (Ctrl+R, Ctrl+T) — must be before fzf-tab
eval "$(fzf --zsh)"

# Autoload Completions (must be after zsh-completions, before fzf-tab)
autoload -U compinit && compinit

zinit cdreplay -q

# fzf-tab must load after compinit
zinit light Aloxaf/fzf-tab

# Tab accepts autosuggestion, Ctrl+F triggers fzf-tab completion
bindkey '^I' autosuggest-accept
bindkey '^F' fzf-tab-complete

# Zoxide (smarter cd)
eval "$(zoxide init --cmd cd zsh)"

# # Set to superior editing mode
set -o vi

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

# get rid of mail notifications on macOS
unset MAILCHECK

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~

PATH="${PATH:+${PATH}:}$HOME/.local/bin:$HOME/dotnet"

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~

export HISTFILE=~/.zsh_history
export HISTSIZE=25000
export SAVEHIST=25000
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_all_DUPS
setopt SHARE_HISTORY
setopt APPENDHISTORY
setopt hist_save_no_dups
setopt hist_find_no_dups

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# ~~~~~~~~~~~~~~~ NVM ~~~~~~~~~~~~~~~~~~~~~~~~

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~

# eval "$(starship init zsh)"

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~

alias v=nvim

# ranger
alias r=ranger

# use FZF for my command History
alias fh='history | fzf | awk '\''{ $1=""; print substr($0,2) }'\'''

# cd
alias ..="cd .."

# Repos
alias dot='cd $DOTFILES'
alias code='cd $REPOS'
alias solved='cd $REPOS/1-Solved/'
alias jones='cd $REPOS/2-JonesRadiology/'
alias config='cd ~/.config/'
alias c="clear"
alias onedrive="cd \$ONEDRIVE"
alias home="cd $HOME"
alias sb="cd $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Chris\ Brain/"

# ls (eza)
alias ls='eza --icons'
alias ll='ls -la'
alias la='eza -a -l --icons'
alias lt='eza -T --icons'

# finds all files recursively and sorts by last modification, ignore hidden files
alias lastmod='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

alias sv='sudoedit'
alias t='tmux'
alias et='v ~/.tmux.conf'
alias st='tmux source-file ~/.tmux.conf'
alias tas='tmux attach-session'
alias e='exit'

# git
alias gc='git commit -m'
alias ga='git add .'
alias gp='git pull'
alias gP='git push'
alias gs='git status'
alias lg='lazygit'
alias gS='git switch'
alias gSn='git switch -c'
alias gl='git --no-pager log --oneline --parents --graph --all'

# config editing
alias ez='v ~/.zshrc'
alias ev='cd ~/.config/nvim/ && v init.lua'
alias szr='source ~/.zshrc'

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

# ~~~~~~~~~~~~~~~ AWS SSM RDP Tunnels ~~~~~~~~~~~~~~~~~~~~~~~~
# tunnel-gateway-NNN — port-forwards RDP (3389) on the instance to localhost:13389.
# Run ONE at a time. RDP client connects to localhost:13389.

# 001 — OTFC
alias tunnel-gateway-001='aws ssm start-session --target i-0f63cad56ef7f58bc \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=3389,localPortNumber=13389" \
  --region ap-southeast-2'

# 003 — PENP (Peninsula Plus)
alias tunnel-gateway-003='aws ssm start-session --target i-0c544ff6e8ca319c4 \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=3389,localPortNumber=13389" \
  --region ap-southeast-2'

# 004 — RSA (Radiology SA)
alias tunnel-gateway-004='aws ssm start-session --target i-08f23181f92ae9c99 \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=3389,localPortNumber=13389" \
  --region ap-southeast-2'

# 005 — BVH (Brighton Veterinary Hospital)
alias tunnel-gateway-005='aws ssm start-session --target i-068bf1671489f0d68 \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=3389,localPortNumber=13389" \
  --region ap-southeast-2'

# 006 — QDC (Quality Dental Care)
alias tunnel-gateway-006='aws ssm start-session --target i-0c2f543fefd8df17f \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=3389,localPortNumber=13389" \
  --region ap-southeast-2'

# 007 — C247 (Care 24-7)
alias tunnel-gateway-007='aws ssm start-session --target i-03a46660b10e7e4d2 \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=3389,localPortNumber=13389" \
  --region ap-southeast-2'

# ~~~~~~~~~~~~~~~ AWS SSM RDS Tunnel ~~~~~~~~~~~~~~~~~~~~~~~~
# sdb (Solved DB) — port-forwards the shared RDS instance to localhost:15432.
# After running: psql -h localhost -p 15432 -U <user> -d <client_db>
alias sdb='aws ssm start-session --target i-0d4670513035ba725 \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "localPortNumber=15432,host=db002.c3mso0q2c8g7.ap-southeast-2.rds.amazonaws.com,portNumber=5432" \
  --region ap-southeast-2'

# sec2 — start Power BI author workflow
alias sec2='bash "/Users/chrisogilvie/Library/CloudStorage/GoogleDrive-chris@solved.dev/Shared drives/GDrive - Team Solved/03 - Global Technical/Scripts/start_powerbi_author_workflow.sh"'

# ~~~~~~~~~~~~~~~ SSH Convenience Functions ~~~~~~~~~~~~~~~~~~~~~~~~
# Shortcuts for local network SSH connections (hosts defined in ~/.ssh/config)

function ssh-imacR() { ssh imacR "$@"; }
function ssh-pi() { ssh pi "$@"; }
function ssh-armbuntu() { ssh armbuntu "$@"; }
function ssh-janice() { ssh janice "$@"; }

# Quick SSH with specific commands
function ssh-run() {
    if [ $# -lt 2 ]; then
        echo "Usage: ssh-run <host> <command>"
        echo "Example: ssh-run imacR 'ls -la'"
        return 1
    fi
    ssh "$1" "${@:2}"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
