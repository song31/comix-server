#!/bin/sh
 
######################################################################
# !!! modify MANGA_DIR as your manga directory!!!
######################################################################
MANGA_DIR="/volume1/manga"
######################################################################


MANGA_DIR_NAME=`basename ${MANGA_DIR}`
MANGA_PARENT_PATH=`dirname ${MANGA_DIR}`
######################################################################
WEB_DIR="/var/services/web/comix-server"
TEMP_DIR="/tmp"
SOURCE="https://github.com/song31/comix-server/archive/master.zip"
######################################################################
chmod 755 ${MANGA_DIR}
rm -rf ${WEB_DIR}
mkdir -p ${WEB_DIR}


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
echo ""


echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 2. Backing up current configuration"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
BACKUP_DIR="/root/comix-server-backup"
mkdir -p ${BACKUP_DIR}
cp ${APACHE_CONF} ${BACKUP_DIR}
cp ${APACHE_CONF}-user ${BACKUP_DIR}
cp ${PHP_CONF} ${BACKUP_DIR}
echo "Backup location: $BACKUP_DIR"


echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 3. Downloading comix-server from github"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
cd ${TEMP_DIR}
wget --no-check-certificate -O comix-server-master.zip ${SOURCE}
unzip comix-server-master.zip
cp -rf comix-server-master/* ${WEB_DIR}
rm -rf comix-server-master.zip comix-server-master
echo "Downloaded from: $SOURCE"
echo ""


echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 4. Configuring comix-server"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
cp ${WEB_DIR}/index.php ${WEB_DIR}/index.php.org
sed -e 's/\"manga\"/\"'"${MANGA_DIR_NAME}"'\"/' ${WEB_DIR}/index.php.org > ${WEB_DIR}/index.php

cp ${WEB_DIR}/handler.php ${WEB_DIR}/handler.php.org
TMP=$(echo ${MANGA_PARENT_PATH} | sed 's/\//\\\//g')
sed -e 's/\"\/volume1\"/\"'"${TMP}"'\"/' ${WEB_DIR}/handler.php.org > ${WEB_DIR}/handler.php

cp ${WEB_DIR}/conf/httpd.conf-comix ${WEB_DIR}/conf/httpd.conf-comix.org
sed -e 's/manga/'"${MANGA_DIR_NAME}"'/' ${WEB_DIR}/conf/httpd.conf-comix.org > ${WEB_DIR}/conf/httpd.conf-comix
echo "Installed at $WEB_DIR"
echo ""


echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 5. Configuring Apache HTTPD"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
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
echo "Modified ${APACHE_CONF} and ${APACHE_CONF}-user"
echo ""

echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 6. Configuring PHP"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
 
if [ -f ${PHP_CONF} ]
then
  if grep -qs "$WEB_DIR:$MANGA_DIR" ${PHP_CONF}
  then
    echo "File ${PHP_CONF} already configured." 
  else
    cp ${PHP_CONF} ${PHP_CONF}.org
    OLD_LINE=`grep open_basedir ${PHP_CONF}.org`
    NEW_LINE=$OLD_LINE":"$WEB_DIR":"$MANGA_DIR
    sed -i "/open_basedir/c\\$NEW_LINE" ${PHP_CONF}
  fi
else
  echo "ERROR: File ${PHP_CONF} does not exist."
fi
echo "Modified ${PHP_CONF}"
echo ""


echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo " 7. Restarting Apache HTTPD"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
 
kill `ps | grep HAVE_PHP | grep root | grep -v grep | awk '{print $1}'`
echo "Waiting for 5 seconds..."
sleep 5

if [ `ps | grep HAVE_PHP | grep root | grep -v grep | wc -l` -eq 0 ]; 
then                                                               
  ${APACHE_CMD}
fi  
echo "Comix-server installed. Enjoy!"
