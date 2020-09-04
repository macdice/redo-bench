#!/bin/sh

INSTALL=~/install
PGDATA=pgdata
LOG=postmaster.log

rm -fr $PGDATA wal-archive
cp -r $PGDATA.backup $PGDATA
cp -r wal-archive.backup wal-archive
touch $PGDATA/recovery.signal
$INSTALL/bin/postgres -D pgdata > $LOG 2>&1 &
PM_PID=$!

while ! grep "ready to accept connections" $LOG > /dev/null ; do
  sleep 1
done

kill $PM_PID
sleep 5

REDO_START="` grep "redo starts at" $LOG | cut -d' ' -f1 `"
REDO_END="` grep "redo done at" $LOG | cut -d' ' -f1 `"
CHECKPOINT_END="` grep "checkpoint complete" $LOG | head -1 | cut -d' ' -f1 `"

awk "BEGIN { printf(\"%s, %s\\n\", $REDO_END - $REDO_START, $CHECKPOINT_END - $REDO_END); }"
