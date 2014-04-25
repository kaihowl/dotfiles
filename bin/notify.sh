#!/bin/bash
echo Sending email to ${NOTIFY_EMAIL:?"You have to set NOTIFY_EMAIL in the env
before."} upon completion.
echo Execute supplied command...

#http://stackoverflow.com/questions/12451278/bash-capture-stdout-to-a-variable-but-still-display-it-in-the-console
exec 5>&1
output=$($1 | tee >(cat - >&5))

echo -e "Subject: $1 done\n$output" | sendmail -f "$NOTIFY_EMAIL" -r "$NOTIFY_EMAIL" "$NOTIFY_EMAIL"
