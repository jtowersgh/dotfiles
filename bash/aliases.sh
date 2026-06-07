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
alias sun="pkill sunshine ; sunshine &"
alias fox="systemd-run --user --scope \
  -p MemoryMax=10G \
  -p MemoryHigh=8G \
  -p ManagedOOMMemoryPressure=kill \
  firefox"
alias electrum="~/Applications/electrum-4.7.1-x86_64.AppImage"
alias getbalance="~/Applications/electrum-4.7.1-x86_64.AppImage daemon -d \
	~/Applications/electrum-4.7.1-x86_64.AppImage getbalance \
	~/Applications/electrum-4.7.1-x86_64.AppImage daemon stop"
alias mcserver="/usr/lib/jvm/java-21-openjdk/bin/java -Xms2G -Xmx4G -jar installer/fabric-server-mc.1.21.11-loader.0.19.2-launcher.1.1.1.jar nogui"
alias fjord="ssh -i ~/.ssh/fjord jeff@10.200.200.1"

# Vim / Neovim
alias vl='NVIM_APPNAME=nvim-luke nvim'

# Original stable config
alias vo='NVIM_APPNAME=nvim-original nvim'

# Directory listing shortcuts
alias l="ls -a"
alias ll="ls -l"
alias la="ls -la"

# --- ComfyUI launch (hybrid container setup) ---
alias comfyui="systemd-inhibit --what=handle-lid-switch:sleep --why='ComfyUI running' docker run -it --rm \
--name comfyui \
--device /dev/kfd --device /dev/dri --group-add video \
-e PATH=/opt/conda/envs/py_3.12/bin:\$PATH \
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
