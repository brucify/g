# g

Script for easy interaction with basic gpg commands.

## Getting started

```bash
$ curl https://raw.githubusercontent.com/brucify/g/main/g -J -o $HOME/.local/bin/g
$ chmod +x $HOME/.local/bin/g
```

## Usage

```
Usage: g {encrypt|decrypt|whoami|recipient|genkey|sign|verify} [filename]
Encrypt, decrypt, sign, verify, or print information about GPG keys.
Use quotes for arguments with spaces.

Commands:
  encrypt <FILE>                      Encrypt a file with recipient specified in ~/.local/.g/gpg_recipient
  decrypt <FILE>                      Decrypt a file with sender key specified in ~/.local/.g/gpg_signer
  decrypt                             Decrypt all .asc and .gpg files in current directory
  whoami                              Display information about the signer key in ~/.local/.g/gpg_signer
  recipient                           Display information about the recipient key in ~/.local/.g/gpg_recipient
  genkey "John Doe <john@doe.com>"    Generate a new key pair with specified
  sign <FILE>                         Sign a file using the signer key in ~/.local/.g/gpg_signer
  verify <SIG> [FILE]                 Verify a detached signature of a file or the standard input
```
