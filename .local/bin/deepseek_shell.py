#!/usr/bin/env python3
import subprocess
import re
import readline  # enables backspace, arrow keys, and input history
import os
import glob
from datetime import datetime
from pathlib import Path

# === Configuration ===
LLAMA_RUN = "/home/jeff/aur/llama.cpp/build/bin/llama-run"
MODEL_PATH = "/home/jeff/models/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf"
TRANSCRIPT_DIR = Path.home() / ".deepseek_logs"
TRANSCRIPT_DIR.mkdir(exist_ok=True)
TRANSCRIPT_FILE = TRANSCRIPT_DIR / f"session_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
LOG_DIR = os.path.expanduser("~/.deepseek_logs")

print(f"[debug] Using llama-run from: {LLAMA_RUN}")
try:
    resolved = subprocess.check_output(["readlink", "-f", LLAMA_RUN]).decode().strip()
    print(f"[debug] Resolved path: {resolved}")
except Exception as e:
    print(f"[debug] Could not resolve path: {e}")

# === Log and Session Chooser ===
def new_log_name():
    """Generate a new log file name."""
    return f"session_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"

def choose_session():
    """Let user continue, rename, or start a new session."""
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
            with open(os.path.join(LOG_DIR, filename), "r") as f:
                context = f.read()
            return os.path.join(LOG_DIR, filename), context

        elif choice == "r":
            for i, s in enumerate(sessions):
                print(f"  [{i + 1}] {s}")
            idx = input("Select session number to rename: ").strip()
            if idx.isdigit() and 1 <= int(idx) <= len(sessions):
                old_name = sessions[int(idx) - 1]
                new_name = input("Enter new name: ").strip()
                if new_name:
                    safe_name = re.sub(r'[^a-zA-Z0-9_\-]', '_', new_name)
                    timestamp = re.search(r'\d{8}_\d{6}', old_name)
                    new_filename = f"session_{timestamp.group()}_{safe_name}.txt" if timestamp else f"{safe_name}.txt"
                    os.rename(os.path.join(LOG_DIR, old_name), os.path.join(LOG_DIR, new_filename))
                    print(f"✅ Renamed to {new_filename}")
            return choose_session()  # re-display after renaming

    # --- if user chooses new or no sessions exist ---
    name = input("\nEnter a name for the new session (optional): ").strip()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    if name:
        safe_name = re.sub(r'[^a-zA-Z0-9_\-]', '_', name)
        filename = f"session_{timestamp}_{safe_name}.txt"
    else:
        filename = f"session_{timestamp}.txt"

    return os.path.join(LOG_DIR, filename), ""

# === Core model runner (debug-friendly) ===
# === Core model runner (safe context size) ===
def run_deepseek(prompt):
    """
    Run DeepSeek model via llama-run with prompt trimming to avoid context overflow.
    Logs stdout/stderr and returncode for debugging.
    """
    # Configuration
    MAX_TOKENS = 2048             # safe token limit for the model
    TEMPERATURE = 0.8             # adjust as needed
    LLAMA_ARGS = [
        "--ctx-size", str(MAX_TOKENS),  # context window
        "--temp", str(TEMPERATURE)
    ]

    # --- Trim prompt by tokens ---
    tokens = prompt.split()  # naive tokenization (whitespace)
    if len(tokens) > MAX_TOKENS:
        tokens = tokens[-MAX_TOKENS:]
        print(f"[debug] Trimming prompt to {len(tokens)} tokens")
    trimmed_prompt = " ".join(tokens)

    # Build command
    cmd = [LLAMA_RUN, MODEL_PATH] + LLAMA_ARGS + [trimmed_prompt]

    # --- Debug logging ---
    debug_log = TRANSCRIPT_DIR / "llama_debug.log"
    with open(debug_log, "a", encoding="utf-8") as dbg:
        dbg.write(f"\n\n=== Run at {datetime.now().isoformat()} ===\n")
        dbg.write("COMMAND:\n")
        dbg.write(" ".join(cmd) + "\n\n")
        dbg.write("PROMPT (first 1000 chars):\n")
        dbg.write(trimmed_prompt[:1000] + ("\n...[truncated]\n" if len(trimmed_prompt) > 1000 else "\n"))
        dbg.flush()

    # Run llama-run
    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="ignore")

    # Log outputs
    with open(debug_log, "a", encoding="utf-8") as dbg:
        dbg.write("\nSTDOUT:\n")
        dbg.write(result.stdout or "<no stdout>\n")
        dbg.write("\nSTDERR:\n")
        dbg.write(result.stderr or "<no stderr>\n")
        dbg.write(f"\nRETURNCODE: {result.returncode}\n")
        dbg.flush()

    # Show debug info if crash
    if result.returncode != 0:
        print(f"[debug] llama-run exited with code {result.returncode}; see {debug_log}")
        stderr_preview = (result.stderr or "")[:2000]
        if stderr_preview:
            print("[debug] stderr (truncated):")
            print(stderr_preview)
        return result.stderr or f"llama-run returned code {result.returncode}"

    # Clean output
    output = result.stdout or ""
    cleaned = re.sub(r"<think>.*?</think>", "", output, flags=re.DOTALL).strip()
    return cleaned

    # If we got here (non-zero), return stderr so the shell can show something
    return (result.stderr or f"llama-run returned code {result.returncode}. Check {debug_log}")

# === Conversation memory ===
def build_prompt(history, user_input, max_ctx_tokens=32768):
    """
    Construct full conversation context as plain text, trimming if necessary.
    Approx 1 token ≈ 4 chars.
    """
    full_prompt = ""
    for role, msg in history:
        full_prompt += f"{role.capitalize()}: {msg}\n"
    full_prompt += f"User: {user_input}\nAssistant:"

    # Trim if too long
    max_chars = max_ctx_tokens * 4
    if len(full_prompt) > max_chars:
        print(f"[debug] Trimming conversation history (was {len(full_prompt)} chars)")
        full_prompt = full_prompt[-max_chars:]
    return full_prompt


# === Transcript logging ===
def log_to_file(line):
    with open(TRANSCRIPT_FILE, "a") as f:
        f.write(line + "\n")

# === Main interactive loop ===
def main():
    print("🧠 DeepSeek Interactive Shell")
    print("Type your prompt and press Enter.")
    print("Commands: /reset to clear memory, /exit to quit.")

    log_path, _ = choose_session()
    print(f"Transcript: {log_path}\n")

    # keep structured conversation history
    history = []

    MAX_CTX_TOKENS = 32768  # model context window
    TOKEN_APPROX_CHARS = 4  # rough chars per token

    while True:
        try:
            user_input = input("> ").strip()
            if not user_input:
                continue

            if user_input.lower() == "/exit":
                print("Exiting DeepSeek shell.")
                break
            if user_input.lower() == "/reset":
                history = []
                print("🧹 Memory cleared.\n")
                continue

            print("\nThinking...\n")

            # Build full prompt from history + current input
            full_prompt = ""
            for role, msg in history:
                full_prompt += f"{role.capitalize()}: {msg}\n"
            full_prompt += f"User: {user_input}\nAssistant:"

            # Trim context if too long
            max_chars = MAX_CTX_TOKENS * TOKEN_APPROX_CHARS
            if len(full_prompt) > max_chars:
                print(f"[debug] Trimming conversation history (was {len(full_prompt)} chars)")
                full_prompt = full_prompt[-max_chars:]

            response = run_deepseek(full_prompt)

            print("=== DeepSeek ===")
            print(response)
            print("================\n")

            # Update structured history
            history.append(("user", user_input))
            history.append(("assistant", response))

            # Log to file
            with open(log_path, "a", encoding="utf-8") as f:
                f.write(f"User: {user_input}\nAssistant: {response}\n\n")
                f.flush()
                os.fsync(f.fileno())

        except KeyboardInterrupt:
            print("\nExiting DeepSeek shell.")
            break
        except Exception as e:
            print(f"Error: {e}")


if __name__ == "__main__":
    main()

