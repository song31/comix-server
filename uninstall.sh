#!/bin/sh

######################################################################
WEB_DIR="/var/services/web/comix-server"
######################################################################
 
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 1. Detecting DSM Version"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
DSM_VERSION=`grep majorversion /etc/VERSION |awk -F'=' '{print $2}' |awk -F'"' '{print $2}'`
if [ "$DSM_VERSION" == "4" ]
then
  APACHE_CONF="/usr/syno/apache/conf/httpd.conf"
  PHP_CONF="/usr/syno/etc/php/user-setting.ini"
  APACHE_CMD="/usr/syno/apache/bin/httpd -DHAVE_PHP"
elif [ "$DSM_VERSION" == "5" ]
then
  APACHE_CONF="/etc/httpd/conf/httpd.conf"
  PHP_CONF="/etc/php/conf.d/user-settings.ini"
  APACHE_CMD="/usr/bin/httpd -DHAVE_PHP"
else
  echo "ERROR: Cannot detect DSM Version. Exiting..."
  exit
fi
echo "Detected DSM version: $DSM_VERSION"

echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 2. Removing comix-server"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

if [ -e ${WEB_DIR} ]
then
  rm -rf ${WEB_DIR}
fi
 

echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 3. Restoring Apache HTTPD"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

if [ -f ${APACHE_CONF}-comix ]
then
  rm -f ${APACHE_CONF}-comix
fi

if [ -f ${APACHE_CONF}-user.org ]
then
  mv -f ${APACHE_CONF}-user.org ${APACHE_CONF}-user
fi

if [ -f ${APACHE_CONF}.org ]
then
  mv -f ${APACHE_CONF}.org ${APACHE_CONF}
fi
 

echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 4. Restoring PHP"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
 
if [ -f ${PHP_CONF}.org ]
then
  mv -f ${PHP_CONF}.org ${PHP_CONF}
fi
 

echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 5. Restarting Apache HTTPD"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
 
kill `ps | grep HAVE_PHP | grep root | grep -v grep | awk '{print $1}'`
echo "Waiting for 5 seconds...   "
sleep 5

if [ `ps | grep HAVE_PHP | grep root | grep -v grep | wc -l` -eq 0 ]; 
then                                                               
  ${APACHE_CMD}
fi  
echo "Comix-server uninstalled."
