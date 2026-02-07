#!/home/jeff/venvs/comfyui-cli/bin/python

import json
import requests
import sys

COMFY_URL = "http://127.0.0.1:8188/prompt"
WORKFLOW_PATH = "/home/jeff/ComfyUI/api/juggernaut_api.json"

def run_prompt(prompt_text):
    with open(WORKFLOW_PATH, "r") as f:
        payload = json.load(f)

    # modify positive prompt node (node 6 in your workflow)
    payload["prompt"]["6"]["inputs"]["text"] = prompt_text

    r = requests.post(COMFY_URL, json=payload)
    r.raise_for_status()

    data = r.json()
    print("Queued prompt_id:", data.get("prompt_id"))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python comfy_gen.py \"your prompt here\"")
        sys.exit(1)

    run_prompt(sys.argv[1])

