# secrets

Place all secrets in this directory. This file contains a description of the required secrets' filenames and content formats.

## contents

* `secrets/secret-key.txt` - plaintext string with output of `openssl rand -hex 64`
* `secrets/db-password.txt` - plaintext string with password for postgresql account
* `secrets/admin-password.txt` - plaintext string with planka admin account password
