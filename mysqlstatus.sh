#!/bin/bash
echo "Live Server MySQL Master Status:"
mysql -e "show master status \G;"
echo
echo "Backup Server MySQL Slave Status:"
ssh root@BACKUP-SERVER 'mysql -e "show slave status \G;"'

echo
echo
echo "Backup Server MySQL Master Status:"
ssh root@BACKUP-SERVER 'mysql -e "show master status \G;"'
echo
echo "Live Server MySQL Slave Status:"
mysql -e "show slave status \G;"
