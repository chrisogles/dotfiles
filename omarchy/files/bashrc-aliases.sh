# Personal aliases. Omarchy's default rc already provides ls/lt (eza), zoxide,
# starship, fzf, mise and the git aliases, so only the gaps are set here.
alias ll='eza -alF --group-directories-first'
alias la='eza -A --group-directories-first'
alias lg='lazygit'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias sb='source ~/.bashrc'
alias eb='nvim ~/.bashrc'
alias c='clear' # overrides Omarchy's c (opencode --auto)
alias gs='git status -sb'
alias gd='git diff'
alias et='nvim ~/.config/tmux/tmux.conf'
alias ev='cd ~/.config/nvim/ && nvim init.lua'
