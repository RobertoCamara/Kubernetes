#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x "$SCRIPT_DIR"/*.sh

echo "🚀 Starting UI setup..."
echo ""

# Function with countdown and key detection
confirm_with_countdown() {
    local prompt="$1"
    local timeout=10
    local default="y"

    echo -n "$prompt (y/N) [default: $default]"

    # Prepare terminal for silent single-key read
    stty -echo -icanon time 0 min 0
    tput sc  # Save cursor position

    for ((i=timeout; i>0; i--)); do
        tput rc  # Restore cursor position
        tput el  # Clear to end of line
        echo -n " - waiting... ${i}s"
        read -t 1 -n 1 response
        if [[ -n "$response" ]]; then
            echo ""
            break
        fi
    done

    # Restore terminal
    stty sane
    echo ""

    # Evaluate response
    case "${response,,}" in  # lowercase
        y|yes|"") return 0 ;;
        *) return 1 ;;
    esac
}

if confirm_with_countdown "👉 Do you want to install Portainer?"; then
    "$SCRIPT_DIR/00-install-portainer.sh"
else
    echo "❌ Portainer installation skipped."
fi

echo ""

if confirm_with_countdown "👉 Do you want to create the Portainer agent?"; then
    "$SCRIPT_DIR/01-create-portainer-agent.sh"
else
    echo "❌ Portainer agent creation skipped."
fi

echo ""

if confirm_with_countdown "👉 Do you want to install Kubevious?"; then
    "$SCRIPT_DIR/02-install-kubevious.sh"
else
    echo "❌ Kubevious installation skipped."
fi

echo ""
echo "🎉 UI setup completed successfully!"