#!/bin/sh

# Usage: g [command] [arguments]
#
# Commands:
#   encrypt <FILE>                      Encrypt a file with recipient specified in ~/.local/.g/gpg_recipient
#   decrypt <FILE>                      Decrypt a file with sender key specified in ~/.local/.g/gpg_signer
#   decrypt                             Decrypt all .asc files in current directory
#   whoami                              Display information about the signer key in ~/.local/.g/gpg_signer
#   recipient                           Display information about the recipient key in ~/.local/.g/gpg_recipient
#   genkey "John Doe <john@doe.com>"    Generate a new key pair with specified
#   sign <FILE>                         Sign a detached signature with the signer key specified in ~/.local/.g/gpg_signer
#   verify <SIG> [FILE]                 Verify a detached signature of a file

GITHUB_URL=https://raw.githubusercontent.com/brucify/g/main/g

# Set the paths for the signer and recipient key files
SIGNER_PATH="$HOME/.local/.g/gpg_signer"
RECIPIENT_PATH="$HOME/.local/.g/gpg_recipient"

# Read the signer and recipient key IDs from the files
SIGNER=$(cat "$SIGNER_PATH")
RECIPIENT=$(cat "$RECIPIENT_PATH")

# Function to encrypt a single file
encrypt_file() {
    FILE="$1"
    gpg -a -e -r "$RECIPIENT" -s -u "$SIGNER" "$FILE"
}

# Function to decrypt a single file
decrypt_file() {
    FILE="$1"
    if [ "${FILE##*.}" = "asc" ] || [ "${FILE##*.}" = "gpg" ]; then
        if gpg -d -u "$SIGNER" "$FILE" > "${FILE%.*}"; then
            echo "Decryption done"
        else
            echo "Decryption failed"
            rm "${FILE%.*}"
        fi
    else
        echo "Unsupported file type: $FILE"
    fi
}

# Function to decrypt all .asc files in the current directory
decrypt_all() {
    for FILE in *.asc *.gpg; do
        if [ -f "$FILE" ]; then
            decrypt_file "$FILE"
        fi
    done
}

# Function to sign a detached signature for a single file
sign_file() {
    FILE="$1"
    gpg -a -u "$SIGNER" -o "$FILE.sig" -b "$FILE"
}

# Function to verify a detached single singature
verify() {
    SIG="$1"
    FILE="$2"
    gpg --verify $SIG $FILE
}

# Function to print information about the signer key
whoami() {
    echo "$SIGNER_PATH"
    echo "-------------------------------"
    gpg -K "$SIGNER"
}

# Function to print information about the recipient key
recipient() {
    echo "$RECIPIENT_PATH"
    echo "-------------------------------"
    gpg -k "$RECIPIENT"
}

# Function to generate a new GPG keypair
genkey() {
    GPG_UID="$1"
    EMAIL=$(echo "$GPG_UID" | sed -n 's/.*<\(.*\)>/\1/p')
    gpg --quick-gen-key "$GPG_UID" rsa4096 cert 2y
    FPR=$(gpg -k --list-options show-only-fpr-mbox | grep "$EMAIL" | awk '{print $1}')
    gpg --quick-add-key "$FPR" rsa4096 sign 2y
    gpg --quick-add-key "$FPR" rsa4096 encrypt 2y
    gpg --quick-add-key "$FPR" rsa4096 auth 2y
}

# Print the usage information for the script
usage() {
    echo "Usage: g {encrypt|decrypt|whoami|recipient|genkey|sign|verify|upgrade|export signer|export recipient} [filename]"
    echo "Encrypt, decrypt, sign, verify, or print information about GPG keys. Use quotes for arguments with spaces."
}

# Parse command line arguments
case "$1" in
    encrypt)
        if [ -n "$2" ]; then
            encrypt_file "$2"
        else
            echo "Usage: g encrypt <FILE>"
            echo "Encrypt a single file with GPG and the recipient key in ~/.local/.g/gpg_recipient."
        fi
        ;;
    decrypt)
        if [ -n "$2" ]; then
            decrypt_file "$2"
        else
            decrypt_all
        fi
        ;;
    sign)
        if [ -n "$2" ]; then
            sign_file "$2"
        else
            echo "Usage: g sign <FILE>"
            echo "Sign a detached signature with the signer key specified in ~/.local/.g/gpg_signer"
        fi
        ;;
    verify)
        if [ -n "$2" ]; then
            verify "$2" "$3"
        else
            echo "Usage: g verify <SIGNATURE> [FILE]"
            echo "Verify a detached signature of a file"
        fi
        ;;
    whoami)
        whoami
        ;;
    recipient)
        recipient
        ;;
    genkey)
        if [ -n "$2" ]; then
            genkey "$2"
        else
            echo "Usage: g genkey \"John Doe <john@doe.com>\""
            echo "Generate a new GPG keypair with the given user ID and add it to your GPG keyring."
        fi
        ;;
    upgrade)
        curl $GITHUB_URL -J -o "$HOME/.local/.g/g"
        ;;
    export)
        case "$2" in
            signer)
                echo "$SIGNER_PATH" >&2
                echo "-------------------------------" >&2
                gpg -a --export "$SIGNER"
                ;;
            recipient)
                echo "$RECIPIENT_PATH" >&2
                echo "-------------------------------" >&2
                gpg -a --export "$RECIPIENT"
                ;;
            *)
                echo "Error: invalid argument. Usage: g export {signer|recipient}"
                exit 1
                ;;
        esac
        ;;
    help)
	usage
        echo ""
        echo "Commands:"
        echo "  encrypt <FILE>                      Encrypt a file with recipient specified in ~/.local/.g/gpg_recipient"
        echo "  decrypt <FILE>                      Decrypt a file with sender key specified in ~/.local/.g/gpg_signer"
        echo "  decrypt                             Decrypt all .asc and .gpg files in current directory"
        echo "  whoami                              Display information about the signer key in ~/.local/.g/gpg_signer"
        echo "  recipient                           Display information about the recipient key in ~/.local/.g/gpg_recipient"
        echo "  genkey \"John Doe <john@doe.com>\"    Generate a new key pair with specified"
        echo "  sign <FILE>                         Sign a file using the signer key in ~/.local/.g/gpg_signer"
        echo "  verify <SIG> [FILE]                 Verify a detached signature of a file or the standard input"
        echo "  export signer                       Export the signer public key in ASCII format"
        echo "  export recipient                    Export the recipient public key in ASCII format"
        echo "  upgrade                             Upgrade g to the latest version from GitHub"
        ;;
    *)
        echo "Unknown command: $1"
	usage
        exit 1
esac

exit 0
