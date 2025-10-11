#!/bin/bash

LOCKFILE="$0.lock"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit

if [ -f "$LOCKFILE" ]; then

    echo "Error: Backup script is running!"

    exit 1

else

    touch "$LOCKFILE" && echo $$ > "$LOCKFILE"
    trap 'rm -f "$LOCKFILE"; exit' INT TERM EXIT

fi

if ! [ -x "$(command -v restic)" ]; then

    echo "Error: restic is not installed. Please install restic before running the script."
    echo "https://restic.readthedocs.io/en/stable/020_installation.html"

    exit 1

fi

if ! [ -f restic.env ]; then

    echo "Please create restic.env"
    echo "Example: cp restic.env.example restic.env"
    echo "Configure the Variabels: RESTIC_REPOSITORY, RESTIC_PASSWORD and RESTIC_FORGET_CONFIG"
    exit 1

fi

if ! [ -f backup-includes.txt ]; then

    echo "Please create backup-includes.txt"
    echo "Exmaple: envsubst < backup-includes.txt.example > backup-includes.txt"
    exit 1

fi

if ! [ -f backup-excludes.txt ]; then

    echo "Please create backup-excludes.txt"
    echo "Example: envsubst < backup-excludes.txt.example > backup-excludes.txt"
    exit 1

fi

if [ "$1" == "init" ]; then

    echo "########## IMPORTANT ##########"
    echo "If you want to backup files outside of your homedirectory, the script must be run as root."
    echo "Change the password for the backup in the restic.env file. Without this password, you won't be able to access the backup. For this reason, you should also store it in another secure location."
    echo "Adjust files backup-excludes.txt and backup-includes.txt according to your needs."
    exit 1

fi

logfile="backup-$(date +%Y-%m-%d).log"

if ! [ -d "logs" ]; then

    mkdir logs

fi

# run pre tasks
if [ -f pre-tasks.sh ]; then

    ./pre-tasks.sh >> logs/"$logfile" 2>&1

fi

# reads the repository and password for the repository from the file restic.env
# shellcheck disable=SC1091
source restic.env

# create backup respository if it does not exist
if ! restic snapshots >/dev/null 2>&1; then

    restic init --repo "$RESTIC_REPOSITORY" >> logs/"$logfile" 2>&1

fi

# create a backup based on files backup-includes.txt and backup-excludes.txt
# shellcheck disable=SC2086
restic --verbose backup --files-from=backup-includes.txt --exclude-file=backup-excludes.txt >> logs/"$logfile" 2>&1

# prune based on $RESTIC_FORGET_CONFIG
restic forget "$RESTIC_FORGET_CONFIG"  >> logs/"$logfile" 2>&1

# run post tasks
if [ -f post-tasks.sh ]; then

    ./post-tasks.sh >> logs/"$logfile" 2>&1

fi
