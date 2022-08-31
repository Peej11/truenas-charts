#!/bin/bash -e
set +o xtrace # To debug, change + to -

# Create user and group that will own the config files (if they don't exist already).
if [ ! "$(getent group ${GID})" ]; then
  # Create group
  addgroup \
    --gid ${GID} \
    appgroup
fi
APP_GROUP=`getent group ${GID} | awk -F ":" '{ print $1 }'`
if [ ! "$(getent passwd ${UID})" ]; then
  # Create user
  adduser \
    --uid ${UID} \
    --shell /bin/bash \
    --no-create-home \
    --ingroup ${APP_GROUP} \
    --system \
    appuser
fi
APP_USER=`getent passwd ${UID} | awk -F ":" '{ print $1 }'`
chown -R ${APP_USER}:${APP_GROUP} ${APP_CONFIG_DIR}

# Generate configs and insert environment variables
PRAW_FILE="${APP_CONFIG_DIR}/praw.ini"
CONFIG_FILE="${APP_CONFIG_DIR}/shreddit.yml"

echo "Generating config files..."
su ${APP_USER} -c "(cd ${APP_CONFIG_DIR}; shreddit -g)"

echo "Inserting variables..."
sed -i -r 's/client_id=(.*)?/client_id='${CLIENT_ID}'/g' ${PRAW_FILE}
sed -i -r 's/client_secret=(.*)?/client_secret='${CLIENT_SECRET}'/g' ${PRAW_FILE}
sed -i -r 's/username=(.*)?/username='${USERNAME}'/g' ${PRAW_FILE}
sed -i -r 's/password=(.*)?/password='${PASSWORD}'/g' ${PRAW_FILE}

sed -i -r 's/hours:(.*)?/hours: '${HOURS}'/g' ${CONFIG_FILE}
sed -i -r 's/max_score:(.*)?/max_score: '${MAX_SCORE}'/g' ${CONFIG_FILE}
sed -i -r 's/sort:(.*)?/sort: '${SORT}'/g' ${CONFIG_FILE}
sed -i -r 's/verbose:(.*)?/verbose: '${VERBOSE}'/g' ${CONFIG_FILE}
sed -i -r 's/clear_vote:(.*)?/clear_vote: '${CLEAR_VOTE}'/g' ${CONFIG_FILE}
sed -i -r 's/item:(.*)?/item: '${ITEM}'/g' ${CONFIG_FILE}
sed -i -r 's/whitelist:(.*)?/whitelist: '${WHITELIST}'/g' ${CONFIG_FILE}
sed -i -r 's/whitelist_ids:(.*)?/whitelist_ids: '${WHITELIST_IDS}'/g' ${CONFIG_FILE}
sed -i -r 's/multi_blacklist:(.*)?/multi_blacklist: '${MULTI_BLACKLIST}'/g' ${CONFIG_FILE}
sed -i -r 's/multi_whitelist:(.*)?/multi_whitelist: '${MULTI_WHITELIST}'/g' ${CONFIG_FILE}
sed -i -r 's/trial_run:(.*)?/trial_run: '${TRIAL_RUN}'/g' ${CONFIG_FILE}
sed -i -r 's/whitelist_distinguished:(.*)?/whitelist_distinguished: '${WHITELIST_DISTINGUISHED}'/g' ${CONFIG_FILE}
sed -i -r 's/whitelist_guilded:(.*)?/whitelist_guilded: '${WHITELIST_GUILDED}'/g' ${CONFIG_FILE}
sed -i -r 's/nuke_hours:(.*)?/nuke_hours: '${NUKE_HOURS}'/g' ${CONFIG_FILE}
sed -i -r 's/keep_a_copy:(.*)?/keep_a_copy: '${KEEP_A_COPY}'/g' ${CONFIG_FILE}
sed -i -r 's/save_directory:(.*)?/save_directory: '${SAVE_DIRECTORY}'/g' ${CONFIG_FILE}
sed -i -r 's/replacement_format:(.*)?/replacement_format: '${REPLACEMENT_FORMAT}'/g' ${CONFIG_FILE}
sed -i -r 's/debug:(.*)?/debug: '${DEBUG}'/g' ${CONFIG_FILE}
sed -i -r 's/wordlist:(.*)?/wordlist: '${WORDLIST}'/g' ${CONFIG_FILE}
sed -i -r 's/batch_cooldown:(.*)?/batch_cooldown: '${BATCH_COOLDOWN}'/g' ${CONFIG_FILE}

# Use cron if schedule specified
if [[ ! -z "${CRON}" ]]; then
  echo "Shreddit will run on the following cron schedule: ${CRON}"

  # Append cron job if not already appended
  if ! crontab -l | cat | grep -qe "shreddit"; then
    crontab -l | { cat; echo "${CRON} su ${APP_USER} -c \"(cd ${APP_CONFIG_DIR}; shreddit)\" > /proc/1/fd/1 2>/proc/1/fd/2"; } | crontab -
  fi

  # Start cron in foreground
  crond -f
else
  su ${APP_USER} -c "(cd ${APP_CONFIG_DIR}; shreddit)"
fi
