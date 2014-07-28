#!/bin/bash
# Export some ENV variables so you don't have to type anything
export AWS_ACCESS_KEY_ID="IAM_USER_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="IAM_USER_SECRET_ACCESS_KEY"
export PASSPHRASE="GPG_OR_SOME_OTHER_PASSPHRASE"

# The S3 destination followed by bucket name
DEST="s3://s3.amazonaws.com/example.com/"

# Your GPG key
#GPG_KEY=YOUR_GPG_KEY

if [ $# -lt 3 ]; then echo "Usage $0 <date> <file> <restore-to>"; exit; fi

duplicity \
    --restore-time $1 \
    --file-to-restore $2 \
    ${DEST} $3

# Reset the ENV variables. Don't need them sitting around
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset PASSPHRASE

