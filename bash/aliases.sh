# ~/.bash/aliases.sh

# Core aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Custom aliases
alias playlist="vim ~/Documents/playlist"
alias bottles="flatpak run com.usebottles.bottles"
alias bashrc="vim ~/.bashrc"
alias deepseek="deepseek_shell.py"
alias sddm="sudo systemctl restart sddm"
alias qwen="qwen.py"
alias pixview="scrcpy-obs.sh"

# Vim / Neovim
alias vim="nvim"

# Directory listing shortcuts
alias l="ls -a"
alias ll="ls -l"
alias la="ls -la"

# --- ComfyUI launch (hybrid container setup) ---
alias comfyui="systemd-inhibit --what=handle-lid-switch:sleep --why='ComfyUI running' docker run -it --rm \
--name comfyui \
--device /dev/kfd --device /dev/dri --group-add video \
-p 8188:8188 \
-v ~/ComfyUI/models:/workspace/ComfyUI/models \
-v ~/ComfyUI/output:/workspace/ComfyUI/output \
-v ~/ComfyUI/custom_nodes:/workspace/ComfyUI/custom_nodes \
-v ~/ComfyUI/user:/workspace/ComfyUI/user \
corundex/comfyui-rocm:latest"

# Gracefully stop ComfyUI container
alias comfyui-stop="echo 'Stopping ComfyUI...' && docker stop comfyui 2>/dev/null || echo 'No container running.'"

# Recover Sunshine
alias recsun="~/.local/bin/recover_sunshine.sh"

# unmount vault
alias lock="cd ~ && fusermount3 -u -z ~/.vault"
