#!/usr/bin/env python3
import subprocess
import sys
import os
import re

def run_model(prompt):
    # Update this path if your llama-run binary is somewhere else
    llama_path = os.path.expanduser('~/aur/llama.cpp/build/bin/llama-run')
    # Update this path to point to your DeepSeek GGUF model
    model_path = os.path.expanduser('~/models/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf')

    if not os.path.isfile(llama_path):
        print(f"Error: llama-run binary not found at {llama_path}")
        sys.exit(1)

    if not os.path.isfile(model_path):
        print(f"Error: model file not found at {model_path}")
        sys.exit(1)

    cmd = [llama_path, model_path, prompt]

    # Use Popen to read stdout line by line
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    output_lines = []
    for line in process.stdout:
        output_lines.append(line)

    process.wait()
    return ''.join(output_lines)

def clean_output(raw_output):
    # Remove everything between <think> and </think>
    cleaned = re.sub(r'<think>.*?</think>', '', raw_output, flags=re.DOTALL)
    return cleaned.strip()

def main():
    if len(sys.argv) < 2:
        print("Usage: deepseek_clean.py \"Your prompt here\"")
        sys.exit(1)

    prompt = ' '.join(sys.argv[1:])
    print(f"Running DeepSeek on: {prompt}\n")

    raw_output = run_model(prompt)
    final_answer = clean_output(raw_output)

    print("Final Answer:\n")
    print(final_answer)

if __name__ == "__main__":
    main()

