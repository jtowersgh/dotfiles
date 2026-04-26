#!/usr/bin/env python3
import subprocess
import re
import readline
import os
from datetime import datetime
from pathlib import Path

# === Configuration ===
LLAMA_RUN = "/home/jeff/aur/llama.cpp/build/bin/llama-run"
MODEL_PATH = "/home/jeff/models/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf"

TRANSCRIPT_DIR = Path.home() / ".deepseek_logs"
TRANSCRIPT_DIR.mkdir(exist_ok=True)
LOG_DIR = str(TRANSCRIPT_DIR)

# Context tuning
MAX_CTX_TOKENS = 2048
CHARS_PER_TOKEN = 4
MAX_CTX_CHARS = MAX_CTX_TOKENS * CHARS_PER_TOKEN

# === Debug ===
print(f"[debug] Using llama-run from: {LLAMA_RUN}")
try:
    resolved = subprocess.check_output(["readlink", "-f", LLAMA_RUN]).decode().strip()
    print(f"[debug] Resolved path: {resolved}")
except Exception as e:
    print(f"[debug] Could not resolve path: {e}")

# === Session Management ===
def choose_session():
    sessions = sorted([f for f in os.listdir(LOG_DIR) if f.startswith("session_")])

    if sessions:
        print("\nAvailable sessions:")
        for i, s in enumerate(sessions):
            print(f"  [{i + 1}] {s}")
        print("  [N] New session")
        print("  [R] Rename a session")

        choice = input("\nSelect session number, N for new, or R to rename: ").strip().lower()

        if choice.isdigit() and 1 <= int(choice) <= len(sessions):
            filename = sessions[int(choice) - 1]
            with open(os.path.join(LOG_DIR, filename), "r", encoding="utf-8") as f:
                context = f.read()
            return os.path.join(LOG_DIR, filename), context

        elif choice == "r":
            idx = input("Select session number to rename: ").strip()
            if idx.isdigit() and 1 <= int(idx) <= len(sessions):
                old_name = sessions[int(idx) - 1]
                new_name = input("Enter new name: ").strip()
                if new_name:
                    safe = re.sub(r'[^a-zA-Z0-9_\-]', '_', new_name)
                    timestamp = re.search(r'\d{8}_\d{6}', old_name)
                    new_filename = f"session_{timestamp.group()}_{safe}.txt"
                    os.rename(os.path.join(LOG_DIR, old_name),
                              os.path.join(LOG_DIR, new_filename))
                    print(f"✅ Renamed to {new_filename}")
            return choose_session()

    name = input("\nEnter a name for the new session (optional): ").strip()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    filename = f"session_{timestamp}_{name}.txt" if name else f"session_{timestamp}.txt"
    return os.path.join(LOG_DIR, filename), ""


# === Context Handling ===
def trim_context(text):
    if len(text) > MAX_CTX_CHARS:
        print(f"[debug] Trimming context ({len(text)} → {MAX_CTX_CHARS} chars)")
        return text[-MAX_CTX_CHARS:]
    return text


def build_prompt(history, user_input):
    prompt = ""

    for role, msg in history:
        prompt += f"{role.capitalize()}: {msg}\n"

    prompt += f"""User: {user_input}
Assistant: (Answer concisely. Do not include internal reasoning or <think> tags.)
"""

    return trim_context(prompt)


# === Model Runner ===
def run_deepseek(prompt):
    cmd = [
        LLAMA_RUN,
        MODEL_PATH,
        "--ctx-size", str(MAX_CTX_TOKENS),
        "--temp", "0.7",
        prompt
    ]

    debug_log = TRANSCRIPT_DIR / "llama_debug.log"

    with open(debug_log, "a", encoding="utf-8") as dbg:
        dbg.write(f"\n\n=== {datetime.now()} ===\n")
        dbg.write("PROMPT:\n")
        dbg.write(prompt[:1000] + "\n...\n")

    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="ignore")

    with open(debug_log, "a", encoding="utf-8") as dbg:
        dbg.write("\nSTDOUT:\n")
        dbg.write(result.stdout or "")
        dbg.write("\nSTDERR:\n")
        dbg.write(result.stderr or "")
        dbg.write(f"\nRET: {result.returncode}\n")

    if result.returncode != 0:
        print(f"[debug] llama-run failed (code {result.returncode})")
        return result.stderr or "Error running model"

    output = result.stdout or ""

    # Remove <think> blocks
    output = re.sub(r"<think>.*?</think>", "", output, flags=re.DOTALL)

    return output.strip()


# === Main Loop ===
def main():
    print("🧠 DeepSeek Interactive Shell")
    print("Commands: /reset /exit\n")

    log_path, existing = choose_session()
    print(f"Transcript: {log_path}\n")

    history = []

    while True:
        try:
            user_input = input("> ").strip()
            if not user_input:
                continue

            if user_input.lower() == "/exit":
                break

            if user_input.lower() == "/reset":
                history = []
                print("🧹 Memory cleared\n")
                continue

            print("\nThinking...\n")

            prompt = build_prompt(history, user_input)
            response = run_deepseek(prompt)

            print("=== DeepSeek ===")
            print(response)
            print("================\n")

            history.append(("user", user_input))
            history.append(("assistant", response))

            history_text = ""
            for role, msg in history:
                history_text += f"{role.capitalize()}: {msg}\n"

            history_text = trim_context(history_text)

            # Rebuild structured history from trimmed text
            history = []
            for line in history_text.strip().split("\n"):
                if line.startswith("User:"):
                    history.append(("user", line[5:].strip()))
                elif line.startswith("Assistant:"):
                    history.append(("assistant", line[10:].strip()))

            with open(log_path, "a", encoding="utf-8") as f:
                f.write(f"User: {user_input}\nAssistant: {response}\n\n")

        except KeyboardInterrupt:
            print("\nExiting.")
            break
        except Exception as e:
            print(f"Error: {e}")


if __name__ == "__main__":
    main()
