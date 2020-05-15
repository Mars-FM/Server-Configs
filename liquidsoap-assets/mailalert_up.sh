#!/bin/bash
printf "Notification from the Mars FM Streaming Server.\n%s\nCiarán" "$(date)" | mail -aFrom:server-updates@marsfm.ie -s "Stream is now back on-air." c.ohaolain@gmail.com marsfm@nuimsu.com

