#!/bin/bash

set -e

THEME_NAME="kindahv"
THEME_FILE="${THEME_NAME}.zsh-theme"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "Error: $THEME_FILE not found in current directory"
    exit 1
fi

if [[ -n "$ZSH" ]] && [[ -d "$ZSH" ]]; then
    echo "Oh My Zsh detected"
    THEME_DIR="$ZSH/custom/themes"
    mkdir -p "$THEME_DIR"
    cp "$THEME_FILE" "$THEME_DIR/"
    echo "Theme installed to $THEME_DIR/$THEME_FILE"
elif [[ -n "$ZDOTDIR" ]] && [[ -d "$ZDOTDIR" ]]; then
    echo "Zsh with ZDOTDIR detected"
    THEME_DIR="$ZDOTDIR/themes"
    mkdir -p "$THEME_DIR"
    cp "$THEME_FILE" "$THEME_DIR/"
    echo "Theme installed to $THEME_DIR/$THEME_FILE"
else
    echo "Standard Zsh detected"
    THEME_DIR="$HOME/.zsh/themes"
    mkdir -p "$THEME_DIR"
    cp "$THEME_FILE" "$THEME_DIR/"
    echo "Theme installed to $THEME_DIR/$THEME_FILE"
    echo "Add 'source $THEME_DIR/$THEME_FILE' to your ~/.zshrc"
fi

echo ""
echo "To activate the theme, add this line to your ~/.zshrc:"
echo "ZSH_THEME=\"$THEME_NAME\""
