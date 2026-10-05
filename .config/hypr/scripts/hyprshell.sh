#!/usr/bin/env bash
set -uo pipefail
umask 077

# --- Configuration ---
AUDIO_FILE="/tmp/ai_command_record.wav"
PID_FILE="/tmp/ai_command_record.pid"

# Unique notification ID so it doesn't overwrite your dictation script notifications
NOTIFY_CMD="notify-send -h string:x-canonical-private-synchronous:sys-ai-cmd"

ENV_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/.env"

if [[ ! -f "$ENV_FILE" ]]; then
    $NOTIFY_CMD -t 5000 -u critical "❌ Missing API key" "Create $ENV_FILE (see .env.example)"
    exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if [[ -z "${GROQ_API_KEY:-}" ]]; then
    $NOTIFY_CMD -t 5000 -u critical "❌ Missing API key" "Set GROQ_API_KEY in $ENV_FILE"
    exit 1
fi

TRANSCRIPTION_MODEL="whisper-large-v3-turbo"
# Exact model ID for Qwen 3.8 27B on Groq
COMMAND_MODEL="qwen/qwen3.8-27b"

# Optimized for terminal commands, Arch Linux tools, and development
CUSTOM_DICTIONARY="Arch Linux, Hyprland, pacman, paru, systemctl, ripgrep, rg, fd, fzf, bat, eza, zoxide, docker, python, xargs, sudo, chmod, chown"

# --- System Prompt ---
# shellcheck disable=SC2016  # prompt is literal, must not expand
COMMAND_SYSTEM_PROMPT='You are a CLI expert agent running directly in an Arch Linux terminal environment.
Your input is a raw speech transcript provided between <transcript> tags.
Your output MUST be a single, valid, and immediately executable shell command.

STRICT OUTPUT RULES:
1. Output ONLY the exact shell command.
2. NEVER use markdown formatting, code blocks, or backticks (e.g., do not output `command`).
3. NEVER add preamble, explanations, confirmations, or labels (e.g., do not output "Here is the command:").
4. Output as pure plain text, ready to be pasted directly into a terminal prompt.

COMMAND GUIDELINES:
- PREFER MODERN CLI TOOLS over traditional coreutils whenever possible. Use `rg` (ripgrep) instead of `grep`, `fd` instead of `find`, `eza` instead of `ls`, and `bat` instead of `cat`.
- Be precise. If the user asks to "find all files containing the word minimax", use `rg "minimax"`.
- If the user asks to "clear all python cache", use `fd -t d "__pycache__" -X rm -r` or `fd -H -I -t d "__pycache__" -x rm -rf`.
- Translate vague intents into the most efficient bash one-liner.'

case "${1:-}" in
start)
    if [ -f "$PID_FILE" ]; then
        exit 0
    fi

    # Start recording
    pw-record --rate=16000 --channels=1 --format=s16 "$AUDIO_FILE" >/dev/null 2>&1 &
    echo $! >"$PID_FILE"

    $NOTIFY_CMD -t 0 -h int:value:100 "🤖 Listening..." "Speak your command intent..." &
    ;;
stop)
    if [ -f "$PID_FILE" ]; then
        # Stop recording
        kill "$(cat "$PID_FILE")"
        rm "$PID_FILE"

        $NOTIFY_CMD -t 0 -h int:value:33 "⏳ Decoding..." "Whisper is processing..."

        # Transcribe audio
        TRANSCRIPT=$(curl -s -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
            -H "Authorization: Bearer $GROQ_API_KEY" \
            -H "Content-Type: multipart/form-data" \
            -F file="@$AUDIO_FILE" \
            -F language="en" \
            -F model="$TRANSCRIPTION_MODEL" \
            -F prompt="$CUSTOM_DICTIONARY" \
            -F response_format="json" | jq -r '.text')

        if [ -z "$TRANSCRIPT" ] || [ "$TRANSCRIPT" == "null" ]; then
            $NOTIFY_CMD -t 5000 -u critical "❌ Error" "Transcription failed."
            exit 1
        fi

        $NOTIFY_CMD -t 0 -h int:value:66 "🧠 Generating..." "AI is writing command..."

        # Generate the terminal command (temperature set to 0.1 for precise, deterministic output)
        JSON_PAYLOAD=$(jq -n \
            --arg system "$COMMAND_SYSTEM_PROMPT" \
            --arg user "<transcript>\n$TRANSCRIPT\n</transcript>\n\nOutput only the exact shell command." \
            --arg model "$COMMAND_MODEL" \
            '{model: $model, messages: [{role: "system", content: $system}, {role: "user", content: $user}], temperature: 0.1, max_tokens: 256}')

        AI_COMMAND=$(curl -s -X POST "https://api.groq.com/openai/v1/chat/completions" \
            -H "Authorization: Bearer $GROQ_API_KEY" \
            -H "Content-Type: application/json" \
            -d "$JSON_PAYLOAD" | jq -r '.choices[0].message.content // empty')

        if [ -z "$AI_COMMAND" ]; then
            $NOTIFY_CMD -t 5000 -u critical "⚠️ Warning" "Command generation failed."
            exit 1
        fi

        # Cleanup: Strip Markdown backticks (```bash or `) if the AI stubbornly adds them
        # shellcheck disable=SC2016  # sed/awk patterns are literal
        CLEAN_COMMAND=$(echo "$AI_COMMAND" | sed 's/^```[a-zA-Z]*//; s/```$//' | sed 's/^`//; s/`$//' | awk '{$1=$1};1')

        # Copy and Paste
        echo -n "$CLEAN_COMMAND" | wl-copy
        sleep 0.1
        wtype -M ctrl -M shift -k v -m shift -m ctrl

        $NOTIFY_CMD -t 3000 -h int:value:100 "✅ Ready" "Command pasted!"
    fi
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
