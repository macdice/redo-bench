INSTALL=~/install
PGDATA=pgdata
LOG=postmaster.log

rm -fr $PGDATA
cp -r $PGDATA.save $PGDATA
$INSTALL/bin/postgres -D pgdata > $LOG 2>&1 &
PM_PID=$!

while ! grep "ready to accept connections" $LOG > /dev/null ; do
  sleep 1
done

kill $PM_PID

REDO_START="` grep "redo starts at" $LOG | cut -d' ' -f1 `"
REDO_END="` grep "redo done at" $LOG | cut -d' ' -f1 `"
CHECKPOINT_START="` grep "checkpoint starting" $LOG | head -1 | cut -d' ' -f1 `"
CHECKPOINT_END="` grep "checkpoint complete" $LOG | head -1 | cut -d' ' -f1 `"

awk "BEGIN { printf(\"%s %s\\n\", $REDO_END - $REDO_START, $CHECKPOINT_END - $CHECKPOINT_START ); }"
