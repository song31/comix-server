#!/bin/sh

############################################################################
WEB_DIR="/var/services/web/comix-server"
APACHE_CONF="/usr/syno/apache/conf/httpd.conf"
PHP_CONF="/usr/syno/etc/php/user-setting.ini"
APACHE_CMD="/usr/syno/apache/bin/httpd -DHAVE_PHP"
############################################################################
 

echo "::::::::::::::::::::::::"
echo "1. Remove comix-server"
echo "::::::::::::::::::::::::"

if [ -f ${WEB_DIR} ]
then
  rm -rf ${WEB_DIR}
fi
 

echo "::::::::::::::::::::::::"
echo "2. Undo Configure Apache"
echo "::::::::::::::::::::::::"

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
 

echo "::::::::::::::::::::::::"
echo "3. Undo Configure PHP"
echo "::::::::::::::::::::::::"
 
if [ -f ${PHP_CONF}.org ]
then
  mv -f ${PHP_CONF}.org ${PHP_CONF}
fi
 

echo "::::::::::::::::::::::::"
echo "4. Restart HTTPD"
echo "::::::::::::::::::::::::"
 
kill `ps | grep HAVE_PHP | grep root | grep -v grep | awk '{print $1}'`
sleep 5
${APACHE_CMD}

