#!/bin/bash
echo  "[`date`] Started Correct WebRoot Permissions" &>> /var/log/rtsecure.log


# Give Ownership To www-data
chown -R www-data:www-data /var/www

# Correct Directory Permissions
find /var/www -type d -exec chmod 0755 {} \;
# Correct Files Permissions
find /var/www -type f -exec chmod 0644 {} \;


echo  "[`date`] Finished Correct WebRoot Permissions" &>> /var/log/rtsecure.log
