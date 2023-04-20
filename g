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

# Get the signer and recipient keys from the configuration files
SIGNER=$(cat ~/.local/.g/gpg_signer)
RECIPIENT=$(cat ~/.local/.g/gpg_recipient)

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
    gpg -K "$SIGNER"
}

# Function to print information about the recipient key
recipient() {
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
    help)
        echo "Usage: g {encrypt|decrypt|whoami|recipient|genkey|sign|verify} [filename]"
        echo "Encrypt, decrypt, sign, verify, or print information about GPG keys."
        echo "Use quotes for arguments with spaces."
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
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: g {encrypt|decrypt|whoami|recipient|genkey|sign|verify} [filename]"
        echo "Encrypt, decrypt, or print information about GPG keys. Use quotes for arguments with spaces."
        exit 1
esac

exit 0
