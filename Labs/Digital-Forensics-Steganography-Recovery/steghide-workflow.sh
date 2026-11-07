#!/bin/bash
# Author: Gresa Hisa
# Steganography workflow — embed and extract hidden text using steghide
# Requires: steghide installed on system

# --------------------------
# CONFIGURATION
# --------------------------
COVER_IMAGE="Secret.jpg"
SECRET_TEXT="message.txt"
OUTPUT_IMAGE="Secret_embedded.jpg"
PASSWORD="YourPasswordHere"
RECOVERED_FILE="RecoveredMessage.txt"

# --------------------------
# 1. Embed hidden text into a JPG file
# --------------------------
embed() {
    echo "[+] Embedding $SECRET_TEXT into $COVER_IMAGE ..."
    steghide embed -cf "$COVER_IMAGE" -ef "$SECRET_TEXT" -p "$PASSWORD" -sf "$OUTPUT_IMAGE"
    echo "[+] Done. Embedded file: $OUTPUT_IMAGE"
}

# --------------------------
# 2. Extract hidden text from the stego image
# --------------------------
extract() {
    echo "[+] Extracting hidden text from $OUTPUT_IMAGE ..."
    steghide extract -sf "$OUTPUT_IMAGE" -p "$PASSWORD" -xf "$RECOVERED_FILE"
    echo "[+] Extraction complete. Recovered text saved to: $RECOVERED_FILE"
}

# --------------------------
# Main
# --------------------------
case "$1" in
    embed)
        embed
        ;;
    extract)
        extract
        ;;
    *)
        echo "Usage: $0 {embed|extract}"
        ;;
esac
