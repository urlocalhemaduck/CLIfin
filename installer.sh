#!/bin/bash
set -euo pipefail

echo "welcome to the CLIfin installer"
echo "please select the OS you are using:"
echo "1. Debian based linux"
echo "2. arch based linux"
echo "3. macOS"
read -r OSofchoiceiwilljudgetheuserson

case "$OSofchoiceiwilljudgetheuserson" in
    1)
        echo "You selected Debian/Ubuntu based Linux"
        OS="debian"
        ;;
    2)
        echo "You selected Arch based Linux"
        OS="arch"
        ;;
    3)
        echo "You selected macOS"
        OS="macos"
        ;;
    *)
        echo "fuck you"
        exit 1
        ;;
esac

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

install_dependencies() {
    case "$OS" in
        debian)
            if ! command -v apt-get >/dev/null 2>&1; then
                echo "apt-get is not available on this system."
                exit 1
            fi
            "$SUDO" apt-get update
            "$SUDO" apt-get install -y mpv jq curl git
            ;;
        arch)
            if ! command -v pacman >/dev/null 2>&1; then
                echo "pacman is not available on this system."
                exit 1
            fi
            "$SUDO" pacman -Syu --noconfirm mpv jq curl git
            ;;
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                echo "Homebrew is required for macOS installs. Please install it first."
                exit 1
            fi
            brew install mpv jq curl git
            ;;
    esac
}

install_dependencies

REPO_DIR="$HOME/CLIfin"
if [ -d "$REPO_DIR/.git" ]; then
    git -C "$REPO_DIR" pull --ff-only
else
    git clone https://github.com/urlocalhemaduck/CLIfin "$REPO_DIR"
fi

chmod +x "$REPO_DIR/CLIfin.sh"

if [ "$OS" = "macos" ]; then
    BIN_DIR="$(brew --prefix)/bin"
else
    if [ "$(id -u)" -eq 0 ]; then
        BIN_DIR="/usr/local/bin"
    else
        BIN_DIR="$HOME/.local/bin"
    fi
fi

mkdir -p "$BIN_DIR"
ln -sf "$REPO_DIR/CLIfin.sh" "$BIN_DIR/CLIfin"

export PATH="$BIN_DIR:$PATH"

SHELL_RC=""
case "$SHELL" in
    */zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    */bash)
        SHELL_RC="$HOME/.bashrc"
        ;;
    *)
        SHELL_RC="$HOME/.profile"
        ;;
esac

touch "$SHELL_RC"
if ! grep -Fq "export PATH=\"$BIN_DIR:\$PATH\"" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
fi

if [ -f "$SHELL_RC" ]; then
    # shellcheck disable=SC1090
    source "$SHELL_RC" 2>/dev/null || true
fi
hash -r 2>/dev/null || true

echo "Installation complete."
echo "You can now run: CLIfin"
echo "If PATH did not update in your current terminal, run: source $SHELL_RC"

