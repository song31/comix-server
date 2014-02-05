#!/bin/sh

############################################################################
# !!! modify MANGA_DIR as your manga directory!!!
############################################################################
MANGA_DIR="/volume1/manga"
############################################################################


############################################################################
WEB_DIR="/var/services/web/comix-server"
APACHE_CONF="/etc/apache2/conf.d/aircomix.conf"
TEMP_DIR="/tmp"
BEFORE_DIR="/var/services/web/comix-server"
SOURCE="https://github.com/song31/comix-server/archive/master.zip"
APACHE_CMD="service apache2 restart"
##########################################################################

MANGA_DIR_NAME=`basename ${MANGA_DIR}`
rm -rf ${WEB_DIR}
mkdir -p ${WEB_DIR}

echo "::::::::::::::::::::::::"
echo " 1. Download Scripts"
echo "::::::::::::::::::::::::"

cd ${TEMP_DIR}
wget --no-check-certificate -O comix-server-master.zip ${SOURCE}
unzip comix-server-master.zip
cp -rf comix-server-master/* ${WEB_DIR}
rm -rf comix-server-master.zip comix-server-master

echo "::::::::::::::::::::::::"
echo " 2. Configure comix"
echo "::::::::::::::::::::::::"

cp ${WEB_DIR}/index.php ${WEB_DIR}/index.php.org
sed -e 's/\"manga\"/\"'"${MANGA_DIR_NAME}"'\"/' ${WEB_DIR}/index.php.org > ${WEB_DIR}/index.php

cp ${WEB_DIR}/handler.php ${WEB_DIR}/handler.php.org
TMP=$(echo ${MANGA_DIR} | sed 's/\//\\\//g')
sed -e 's/\"\/volume1\"/\"'"${TMP}"'\"/' ${WEB_DIR}/handler.php.org > ${WEB_DIR}/handler.php

echo "::::::::::::::::::::::::"
echo " 3. Configure Apache"
echo "::::::::::::::::::::::::"

cp ${WEB_DIR}/conf/httpd.conf-comix ${WEB_DIR}/conf/httpd.conf-comix.org
sed -e 's/manga/'"${MANGA_DIR_NAME}"'/' ${WEB_DIR}/conf/httpd.conf-comix.org > ${WEB_DIR}/httpd.conf-comix

TMP_1=$(echo ${BEFORE_DIR} | sed 's/\//\\\//g')
TMP_2=$(echo ${WEB_DIR} | sed 's/\//\\\//g')
sed -e 's/'"${TMP_1}"'/'"${TMP_2}"'/' ${WEB_DIR}/httpd.conf-comix > ${APACHE_CONF}

echo "::::::::::::::::::::::::"
echo " 4. Restart Apache"
echo "::::::::::::::::::::::::"

${APACHE_CMD}
