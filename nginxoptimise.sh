#!/bin/bash
sed -i "s/worker_processes.*/worker_processes `cat /proc/cpuinfo | grep processor | wc -l`;/" /etc/nginx/nginx.conf

nginx -t && service nginx reload 
if [ $? -ne 0 ]
then
        echo "$(echo -n "IP Address: "; curl -s http://169.254.169.254/latest/meta-data/public-ipv4; echo; ifconfig)" | mail -s "Unable To Reload Nginx On $(hostname -f)" Mitesh.Shah@rtcamp.com
fi
