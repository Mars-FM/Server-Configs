#!/bin/bash
printf "Notification from the Mars FM Streaming Server.\n%s\nCiarán is a big willy" "$(date)" | mail -aFrom:server-updates@marsfm.ie -s "Dead-air detected, fallback triggered." c.ohaolain@gmail.com marsfm@nuimsu.com
