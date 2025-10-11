# Backup with restic

Backup project to create backups with restic

https://restic.net/

```
3 copies
2 different medias
1 offisite copy
```

## Default backup retention

The script keeps

* all snapshots from the last 24 hours
* all daily backups for the last 7 days
* weekly backups for the past 5 weeks
* monthly backups for the last 12 months
* yearly backups for the last 75 years

## Setup

```bash
envsubst < backup-includes.txt.example > backup-includes.txt
```

```bash
envsubst < backup-excludes.txt.example > backup-excludes.txt
```

```bash
cp restic.env.example restic.env
```

Configure the variables: `RESTIC_REPOSITORY`, `RESTIC_PASSWORD` and `RESTIC_FORGET_CONFIG`

## Pre- and post-tasks

If you want to run pre-tasks or post-tasks, you can put them into `the pre-tasks.sh` and `post-tasks.sh` files.

## Create backup

```bash
./backup.sh
```
