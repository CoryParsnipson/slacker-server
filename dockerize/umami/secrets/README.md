# secrets

Place all secrets in this directory. This file contains a description of the required secrets' filenames and content formats.

## contents

* `secrets/app-secret.txt` - plaintext random string
* `secrets/default.env` - envfile containing POSTGRES_USER, POSTGRES_PASSWORD, and POSTGRES_DB (this is an env file because the variables need to be concatenated to form DATABASE_URL)
