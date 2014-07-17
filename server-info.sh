#!/bin/bash
echo -e "\n"
echo -e "Model Name : $(cat /proc/cpuinfo | grep "model name" | cut -d: -f2 | head -n1) \n"
echo -e "Architecture : $(arch) \n"
echo -e "CPU Cores : $(nproc) \n"
echo -e "OS : $(lsb_release -d | cut -d':' -f2 | sed 's/^[ \t]*//') \n"
echo  -e "RAM & Swap Usage " && free -m | grep -v 'buffers/cache' && echo -e "\n"
echo "HDD Usage " && df -h && echo -e "\n"
echo "NGINX : " && nginx -V 
if [ $? != 0 ] ; then
	echo "NGINX Not found"
fi 
echo -e "\n"

echo "PHP Version : " && php -v 2>/dev/null
if [ $? != 0 ] ; then
        echo "PHP Not found"
fi
echo -e "\n"

echo "MySQL Version : " && mysql -V 2>/dev/null 
if [ $? != 0 ] ; then
        echo "MySQL Not found"
fi
echo -e "\n"

echo "Open-ssh Version : " && ssh -V
if [ $? != 0 ] ; then
        echo "OpenSSH  Not found"
fi
echo -e "\n"

