# ~/.zprofile — login shell (runs once per session, before .zshrc)

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Android SDK
export ANDROID_SDK="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK/platform-tools:$PATH"

# PostgreSQL
export PATH="/Library/PostgreSQL/15/bin:$PATH"

# Python
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# Local bin
export PATH="$HOME/bin:$PATH"
