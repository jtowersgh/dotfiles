#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

#my custom aliases
#alias godot="godot --rendering-driver opengl3"
alias bashrc="vim ~/.bashrc"

PS1='[\u@\h \W]\$ '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

#my custom aliases
alias playlist="vim ~/Documents/playlist"
alias bottles="flatpak run com.usebottles.bottles"
alias bashrc="vim ~/.bashrc"
alias vim="nvim"
alias l="ls -a"
alias ll="ls -l"
alias la="ls -la"
