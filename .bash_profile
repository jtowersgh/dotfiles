# ~/.bash_profile

# load .profile if it exists
if [ -f ~/.profile ]; then
  . ~/.profile
fi

# ensure .bashrc runs for interactive shells
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
