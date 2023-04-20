# g

Script for easy interaction with basic gpg commands.

## Getting started

```bash
$ curl https://raw.githubusercontent.com/brucify/g/main/g -J -o $HOME/.local/bin/g
$ chmod +x $HOME/.local/bin/g
$ g config signer <YOUR KEY ID HERE>
$ g config recipient <THEIR KEY ID HERE>
```

## Usage

```
Usage: g {encrypt|decrypt|whoami|recipient|genkey|sign|verify|upgrade|export signer|export recipient} [filename]
Encrypt, decrypt, sign, verify, or print information about GPG keys. Use quotes for arguments with spaces.

Commands:
  encrypt <FILE>                      Encrypt a file with recipient specified in ~/.local/.g/gpg_recipient
  decrypt <FILE>                      Decrypt a file with sender key specified in ~/.local/.g/gpg_signer
  decrypt                             Decrypt all .asc and .gpg files in current directory
  whoami                              Display information about the signer key in ~/.local/.g/gpg_signer
  recipient                           Display information about the recipient key in ~/.local/.g/gpg_recipient
  genkey "John Doe <john@doe.com>"    Generate a new key pair with specified
  sign <FILE>                         Sign a file using the signer key in ~/.local/.g/gpg_signer
  verify <SIG> [FILE]                 Verify a detached signature of a file or the standard input
  export signer                       Export the signer public key in ASCII format
  export recipient                    Export the recipient public key in ASCII format
  upgrade                             Upgrade g to the latest version from GitHub
  config signer [KEY_ID]              Set or display the signer key ID in ~/.local/.g/gpg_signer
  config recipient [KEY_ID]           Set or display the recipient key ID in ~/.local/.g/gpg_recipient
```
