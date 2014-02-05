#!/bin/sh

############################################################################
WEB_DIR="/var/services/web/comix-server"
APACHE_CONF="/etc/apache2/conf.d/aircomix.conf"
APACHE_CMD="service apache2 restart"
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

if [ -f ${APACHE_CONF} ]
then
  rm -f ${APACHE_CONF}
fi


echo "::::::::::::::::::::::::"
echo "3. Restart Apache"
echo "::::::::::::::::::::::::"

${APACHE_CMD}

