#!/bin/sh
 
############################################################################
# !!! modify MANGA_DIR as your manga directory!!!
############################################################################
MANGA_DIR="/volume1/manga"
############################################################################


############################################################################
WEB_DIR="/var/services/web/comix-server"
APACHE_CONF="/usr/syno/apache/conf/httpd.conf"
PHP_CONF="/usr/syno/etc/php/user-setting.ini"
APACHE_CMD="/usr/syno/apache/bin/httpd -DHAVE_PHP"
TEMP_DIR="/tmp"
SOURCE="https://github.com/song31/comix-server/archive/master.zip"
############################################################################

MANGA_DIR_NAME=`basename ${MANGA_DIR}`
MANGA_PARENT_PATH=`dirname ${MANGA_DIR}`
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
TMP=$(echo ${MANGA_PARENT_PATH} | sed 's/\//\\\//g')
sed -e 's/\"\/volume1\"/\"'"${TMP}"'\"/' ${WEB_DIR}/handler.php.org > ${WEB_DIR}/handler.php

cp ${WEB_DIR}/conf/httpd.conf-comix ${WEB_DIR}/conf/httpd.conf-comix.org
sed -e 's/manga/'"${MANGA_DIR_NAME}"'/' ${WEB_DIR}/conf/httpd.conf-comix.org > ${WEB_DIR}/conf/httpd.conf-comix


echo "::::::::::::::::::::::::"
echo " 3. Configure Apache"
echo "::::::::::::::::::::::::"
 
if [ -f ${APACHE_CONF}-user ]
then
  cp ${WEB_DIR}/conf/httpd.conf-comix ${APACHE_CONF}-comix
  if grep -qs "Include ${APACHE_CONF}-comix" ${APACHE_CONF}-user
  then
    echo "File ${APACHE_CONF}-user already configured." 
  else
    cp ${APACHE_CONF}-user ${APACHE_CONF}-user.org
    echo "" >> ${APACHE_CONF}-user
    echo "Include ${APACHE_CONF}-comix" >> ${APACHE_CONF}-user
  fi
else
  echo "ERROR: File ${APACHE_CONF}-user does not exist."
fi

if [ -f ${APACHE_CONF} ]
then
  if grep -qs "Include ${APACHE_CONF}-comix" ${APACHE_CONF}
  then
    echo "File ${APACHE_CONF} already configured." 
  else
    cp ${APACHE_CONF} ${APACHE_CONF}.org
    echo "" >> ${APACHE_CONF}
    echo "Include ${APACHE_CONF}-comix" >> ${APACHE_CONF}
  fi
else
  echo "ERROR: File ${APACHE_CONF} does not exist."
fi
 

echo "::::::::::::::::::::::::"
echo " 4. Configure PHP"
echo "::::::::::::::::::::::::"
 
if [ -f ${PHP_CONF} ]
then
  if grep -qs "$WEB_DIR:$MANGA_DIR" ${PHP_CONF}
  then
    echo "File ${PHP_CONF} already configured." 
  else
    mv ${PHP_CONF} ${PHP_CONF}.org
    OLD_LINE=`grep open_basedir ${PHP_CONF}.org`
    NEW_LINE=$OLD_LINE":"$WEB_DIR":"$MANGA_DIR
    echo $NEW_LINE > ${PHP_CONF}
    sed 1d ${PHP_CONF}.org >> ${PHP_CONF}
  fi
else
  echo "ERROR: File ${PHP_CONF} does not exist."
fi


echo "::::::::::::::::::::::::"
echo " 5. Restart HTTPD"
echo "::::::::::::::::::::::::"
 
kill `ps | grep HAVE_PHP | grep root | grep -v grep | awk '{print $1}'`
echo "Wait 5 seconds...   "
sleep 5
${APACHE_CMD}

