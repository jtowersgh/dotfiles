# ~/.bashrc

# Only run for interactive shells
[[ $- != *i* ]] && return

# Source modular config files
for file in ~/Projects/dotfiles/bash/{aliases.sh,exports.sh,prompt.sh,functions.sh}; do
    [[ -f $file ]] && . "$file"
done

# Optional: fzf setup
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Source bootstrap functions (manual execution)
[ -f ~/Projects/dotfiles/bash/bootstrap.sh ] && source ~/Projects/dotfiles/bash/bootstrap.sh

# Define manual bootstrap alias
alias bootstrap='bootstrap'

