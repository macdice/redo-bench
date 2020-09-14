#!/bin/sh

INSTALL=~/install
PGDATA=pgdata

rm -fr $PGDATA $PGDATA.crash

$INSTALL/bin/initdb -D $PGDATA
echo "max_wal_size=20GB" >> $PGDATA/postgresql.conf
echo "checkpoint_timeout=60min" >> $PGDATA/postgresql.conf
echo "synchronous_commit=off" >> $PGDATA/postgresql.conf
echo "log_line_prefix='%n %b %p '" >> $PGDATA/postgresql.conf
echo "log_checkpoints=on" >> $PGDATA/postgresql.conf
$INSTALL/bin/pg_ctl -D $PGDATA start
$INSTALL/bin/pgbench -i -s10 postgres
$INSTALL/bin/psql postgres -c checkpoint

$INSTALL/bin/pgbench -Mprepared -Mprepared -c8 -j8 -t1000000 postgres

$INSTALL/bin/pg_ctl -D $PGDATA stop -m immediate

sleep 5

mv $PGDATA $PGDATA.crash

