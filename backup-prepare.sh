#!/bin/sh

INSTALL=~/install
PGDATA=pgdata

rm -fr $PGDATA $PGDATA.backup

$INSTALL/bin/initdb -D $PGDATA
echo "max_wal_size=20GB" >> $PGDATA/postgresql.conf
echo "checkpoint_timeout=60min" >> $PGDATA/postgresql.conf
echo "synchronous_commit=off" >> $PGDATA/postgresql.conf
echo "log_line_prefix='%n %b %p '" >> $PGDATA/postgresql.conf
echo "log_checkpoints=on" >> $PGDATA/postgresql.conf
echo "archive_mode=on" >> $PGDATA/postgresql.conf
echo "archive_command = 'gzip -1 -c %p > /home/tmunro/projects/redo-bench/wal-archive/%f.gz'" >> $PGDATA/postgresql.conf
echo "restore_command = 'gunzip -c /home/tmunro/projects/redo-bench/wal-archive/%f.gz > %p.tmp && mv %p.tmp %p'" >> $PGDATA/postgresql.conf
$INSTALL/bin/pg_ctl -D $PGDATA start
$INSTALL/bin/pgbench -i -s10 postgres
$INSTALL/bin/pg_basebackup -h localhost --checkpoint=fast -Xn -D $PGDATA.backup
$INSTALL/bin/pgbench -c8 -j8 -t1000000 postgres
$INSTALL/bin/pg_ctl -D $PGDATA stop -m immediate

sleep 5

mv wal-archive wal-archive.backup

