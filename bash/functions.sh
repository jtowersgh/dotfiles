# ~/.bash/functions.sh

# Example: quick update function
update_system() {
    sudo pacman -Syu
}

# ComfUI function

comfy-gen () {
  if [ -z "$1" ]; then
    echo "Usage: comfy-gen \"your prompt text\""
    return 1
  fi

  WORKFLOW="$HOME/ComfyUI/api/juggernaut_api.json"

  jq \
    --arg prompt "$1" \
    --argjson seed "$(date +%s%N)" \
    '
    .prompt["6"].inputs.text = $prompt
    | .prompt["3"].inputs.seed = $seed
    ' "$WORKFLOW" \
  | curl -s -X POST http://127.0.0.1:8188/prompt \
      -H "Content-Type: application/json" \
      -d @-

}

writefile() {
	local file="$1"
	echo "Paste text. Press Ctrl-D when finished."
	cat > "$file"
}

# Clear the screen and terminal scrollback.
clear() {
    printf '\e[2J\e[H\e[3J'
}

# Execute a multiline command block in a child Bash and capture all output.
capture_last() {
    local tmp="/tmp/last-command-block.txt"
    local script
    local status

    script=$(cat) || return 1
    : > "$tmp"

    bash -c "$script" < /dev/tty 2>&1 | tee "$tmp"
    status=${PIPESTATUS[0]}

    printf '\n===== COMMAND BLOCK COMPLETE =====\n'
    printf 'Output saved to: %s\n' "$tmp"
    printf 'Exit status: %s\n' "$status"

    return "$status"
}

# View the most recently captured command-block output.
show_last_output() {
    local tmp="/tmp/last-command-block.txt"

    if [ ! -f "$tmp" ]; then
        printf 'No captured command-block output exists.\n'
        return 1
    fi

    less "$tmp"
}
