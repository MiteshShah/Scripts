#!/bin/bash

tail -n1 /var/log/rsnapshot.log | grep -v "completed successfully" \
&& grep $(date +"%d/%b/%Y") /var/log/rsnapshot.log | mail -s "Local backup on soy.rtcamp.com failed" sys@rtcamp.com

