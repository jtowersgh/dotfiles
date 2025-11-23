# ~/.bash/exports.sh

# User PATH additions
export PATH="$HOME/.local/bin:$PATH"

# Optional global variables
# export EDITOR=nvim

# Source Hugging Face token (if present)
if [ -f ~/.config/secrets/hf.sh ]; then
	source ~/.config/secrets/hf.sh
fi

# Force use of 7900xtx graphics card for LLM
export HIP_VISIBLE_DEVICES=GPU-4e53244067186199
