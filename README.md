comix-server
============

Comix-server is a PHP-based AirComics Server acting just as the Windows
version. Originally it was written to run on the Synology NAS. However,
it can run on any platforms where Apache HTTP Server runs, such as
Ubuntu Linux or OS X.

Comix-server is compatible with both AirComix (old version) and AirComics 
(new version) app.


## How to install

- Installer now supports both **DSM 5.x** and 4.x.
- Log in to the Synology DSM and make a shared folder, for example,
  named "manga". This directory will be your manga directory.
- Enable SSH and Web Station.
- Download [comix-server-master.zip](https://github.com/song31/comix-server/archive/master.zip),
  unzip it, and copy install.sh and uninstall.sh to your manga directory.
- Connect to your Synology server using SSH as root and go to the manga 
  directory (/volume1/manga). The path might be different in your
  system. Modify *MANGA_DIR* in install.sh if the path is not /volume1/manga.   
  ```
  DiskStation> cd /volume1/manga
  ```
- Give the execution permission on install.sh.   
  ```
  DiskStation> chmod 755 install.sh
  ```
- Run install.sh.   
  ```
  DiskStation> ./install.sh
  ```
  
For more information about installation, please refer to the [INSTALL.md](https://github.com/song31/comix-server/blob/master/INSTALL.md).  


## How to uninstall

- Run uninstall.sh on the Synology shell.

Special thanks to "20eung" for providing the install & uninstall script.


## How to run

Start Apache HTTP Server. Usually the Apache HTTP process automatically starts when the machine boots up.


## How to use

- Copy your comic collection to the manga directory.
- Start the AirComics app on iPhones or iPads and add comix-server as AIRCOMICS Server.
  Select the **Enter Address Manually** menu to fill in your comix-server information.
  Note that default port number is 31257.
- Enjoy!


## How to contribute

Bug reports and pull requests are always welcome.


## FAQ

Q) Which Synology DSM versions are supported?   
A) The install script was tested only on DSM 5.x and 4.x. However, comix-server itself is just a web application written in PHP so it should run on any platforms with HTTPD & PHP.

Q) Which file formats are supported?  
A) Comix-server supports archive formats such as ZIP, RAR, CBZ, and CBR.
   Also it supports most image formats such as JPG, GIF, PNG, and TIFF.

Q) Does comix-server really support RAR?
   Yes if your system has PHP extension for RAR. You can easily install 
   it on Linux platform (see <http://www.php.net/manual/en/rar.installation.php> 
   for detail), but it seems hard to install it on Synology servers.

Q) Do I need to uncompress ZIP or RAR files?  
A) No. Like Windows version, just put them in your manga directory.
   However, comix-server does not handle double-zipped files.

Q) Can I have multiple directories under my manga directory?  
A) Yes. You can make any directory structure. 
   One restriction is that image files can be only in a leaf directory, 
   which does not have any child directory.

Q) How can I change the port number?  
A) See /usr/syno/apache/conf/httpd.conf-comix.

Q) How can I change the manga directory?  
A) See comments in handler.php. You need to modify handler.php, index.php, 
   user-setting.ini, and httpd.conf-comix.

Q) Does comix-server support password protection?  
A) Yes, using Apache's basic authentication mechanism. Refer to 
   <http://www.cs.duke.edu/csl/faqs/web/basic-auth> to know how to
   configure it. Note that the user name should be AirComix (case
   sensitve) and .htaccess file should be in /var/services/web/comix where
   handler.php exists. If there is no htpasswd util in your system, 
   you can create the password file on other machines and copy it to
   your system.
   
Q) I cannot see some files under the manga directory. What is the problem?   
A) If you have a directory which contains image files as well as ZIP files, 
   move image files (or ZIP files) to another directory. 
   A single directory can have multiple image files or multiple ZIP files, 
   but not both.  


## License

Comix-server is free software licensed under [GNU GPLv3](http://www.gnu.org/licenses/gpl.txt). 
Everyone is permitted to copy, modify, and redistribute it.
