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

