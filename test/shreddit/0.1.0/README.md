# Shreddit Dockerized
A Docker wrapper for [Shreddit](https://github.com/x89/Shreddit), the Reddit auto-delete tool. Easily automated via cron!

- Forked from: https://github.com/MitchTalmadge/shreddit-dockerized/
- GitHub Link: https://github.com/Peej11/truenas-charts/
- Docker Hub Link: https://hub.docker.com/r/peej11/shreddit-dockerized

# Motivation
The idea with this container was expand on the capabilities of MitchTalmadge/shreddit-dockerized/ and expose all shreddit parameters as environment variables and create a chart template that easily works with the TrueNAS SCALE GUI.

# Usage
Run the container and provide the environment variables however you prefer. CLI, env file, etc.

```
docker run -e CLIENT_ID=<client_id> -e CLIENT_SECRET=<client_secret> ... peej11/shreddit-dockerized:1.1
```

## Shreddit Config
**Everything** is exposed as an environment variable so you need to provide everything required to run the container.

```
CLIENT_ID
CLIENT_SECRET
USERNAME
PASSWORD
HOURS
MAX_SCORE
SORT
VERBOSE
CLEAR_VOTE
ITEM
WHITELIST
WHITELIST_IDS
MULTI_BLACKLIST
MULTI_WHITELIST
TRIAL_RUN
WHITELIST_DISTINGUISHED
WHITELIST_GUILDED
NUKE_HOURS
KEEP_A_COPY
SAVE_DIRECTORY
REPLACEMENT_FORMAT
DEBUG
WORDLIST
BATCH_COOLDOWN
```

## Run Mode
There are two ways to run shreddit in this container: once-then-done, or periodically via cron.

### Once-then-done
This is the default behavior. No extra configuration needed.

When the container starts, it will immediately run shreddit and then exit. 

### Cron
To run shreddit on a cron schedule, just set the CRON env var with the schedule. For example:

**Every Minute** (Not recommended)
```
CRON=* * * * *
```

**Every Hour at Minute 0**
```
CRON=0 * * * *
```

**Every Day at Hour 0, Min 0**
```
CRON=0 0 * * *
```

That's it!

## UID & GID
The config directory and files created will be owned by default by the user and group with UID and GID `1000`.

To choose your own UID/GID, just set the env vars:

```
UID=1001
GID=1001
```

# Support / Bugs / Feedback
If something is not working right, [report it](https://github.com/Peej11/truenas-charts/issues)! We'll get it squared away quickly.
