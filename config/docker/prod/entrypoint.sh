#!/bin/bash

cmd="$@"

echo "copying config/database.yml.docker -> config/database.yml"
cp /noosfero/config/database.yml.docker /noosfero/config/database.yml

function_postgres_ready() {
ruby << END
require 'pg'
begin
  PG.connect(dbname: "$POSTGRES_DB", user: "$POSTGRES_USER", password: "$POSTGRES_PASSWORD", host: "postgres")
rescue
  exit -1
else
  exit 0
end
END
}

until function_postgres_ready; do
  >&2 echo "POSTGRES IS UNAVAILABLE, SLEEP"
  sleep 1
done

echo "POSTGRES IS UP, CONTINUE"

dump_file="/noosfero/dump/${NOOSFERO_DUMP_FILE}"
if [ -f $dump_file ] ; then
  echo ">>>>> DUMP FILE FOUND PREPARING DATABASE <<<<<"
  bundle exec rake db:drop
  bundle exec rake db:create

  echo ">>>>> LOADING DATABASE DUMP <<<<<"
  yes | bundle exec rake restore BACKUP=$dump_file
fi

if bundle exec rake db:exists; then
  echo ">>>>> DATABASE DETECTED APPLYING MIGRATIONS <<<<<"
  bundle exec rake db:migrate
else
  echo ">>>>> NO DATABASE DETECTED CREATING A NEW ONE <<<<<"
  bundle exec rake db:create
  bundle exec rake db:schema:load
  bundle exec rake db:migrate
fi

echo ">>>>> COMPILING ASSETS <<<<<"
bundle exec rake assets:precompile

pidfile='/noosfero/tmp/pids/server.pid'
if [ -f $pidfile ] ; then
	echo 'Server PID file exists. Removing it...'
	rm $pidfile
fi

exec $cmd
