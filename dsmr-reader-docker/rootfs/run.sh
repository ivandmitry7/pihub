#!/bin/bash

echo ""
echo "Start DSMR Reader"

set -eo pipefail
COMMAND="$@"

# 100% permissions fail safe
chown -R dsmr: /home/dsmr /var/www/dsmrreader/
if [ -e '/dev/ttyUSB0' ] ; then sudo chmod 666 /dev/ttyUSB* ; fi

# Fix possible staled pid files
rm -f /var/tmp/*.pid

# Check if we're able to connect to the database instance
# already. The port isn't required for postgresql.py but
# it is added for the sake of completion.
DB_PORT=${DB_PORT:-5432}

echo "Trying to connect to PostgreSQL database"

cmd=$(find /usr/lib/postgresql/ -name pg_isready)
cmd="$cmd -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t 1"

timeout=60
while ! $cmd >/dev/null 2>&1; do
    timeout=$(expr $timeout - 1)
    if [[ $timeout -eq 0 ]]; then
        echo ""
        echo "Could not connect to PostgreSQL database server. Aborting..."
        sleep 1
        exit 1
    fi
    echo -n "."
    sleep 1
done

echo ""
echo "Successfully connected to PostgreSQL database"

# Run migrations
su dsmr -c "python3 manage.py migrate --noinput"
su dsmr -c "python3 manage.py collectstatic --noinput"

# Override command if needed - this allows you to run
# python3 manage.py for example. Keep in mind that the
# WORKDIR is set to /home/dsmr/app.
if [ -n "$COMMAND" ]; then
	echo "ENTRYPOINT: Executing override command"
	exec $COMMAND
fi

if [ -z "${DSMR_USER}" ] || [ -z "$DSMR_EMAIL" ] || \
   [ -z "${DSMR_PASSWORD}" ]; then
	echo "DSMR web credentials not set. Exiting."
	exit 1
fi

# Create an admin user
su dsmr -c "python3 manage.py shell -i python << PYTHON
from django.contrib.auth.models import User
if not User.objects.filter(username='${DSMR_USER}'):
	User.objects.create_superuser(
    '${DSMR_USER}', '${DSMR_EMAIL}', '${DSMR_PASSWORD}'
  )
	print('${DSMR_USER} created')
else:
	print('${DSMR_USER} already exists')
PYTHON"

# Run supervisor
/usr/bin/supervisord -n
