comix-server
============

Comix-server is a PHP-based AirComics Server acting just as the Windows
version. Originally it was written to run on the Synology NAS. However,
it can run on any platforms where Apache HTTP Server runs, such as
Ubuntu Linux or OS X.

Comix-server works with both AirComix (old version) and AirComics (new
version) app.


## How to install

- Log in to the Synology DSM and make a shared folder, for example,
  named "manga". This directory will be your manga directory.
- Enable SSH and Web Station.
- Download [install.sh](https://github.com/song31/comix-server/blob/master/install.sh) 
  and copy it to your manga directory.
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
  
For more information, please refer to the [step-by-step guide](https://github.com/song31/comix-server/wiki/Step-by-Step-Configuration-Guide).  


## How to uninstall

- Download [uninstall.sh](https://github.com/song31/comix-server/blob/master/uninstall.sh) 
  and run it on the Synology shell.

Special thanks to "20eung" for providing the install & uninstall script.


## How to run

The Apache HTTP process automatically starts and is always running on
the Synology server.


## How to use

- Copy your comic collection to the manga directory.
- Start AirComics app on your iPhone/iPad and add your Synology server.
  Touch **Enter Address Manually** and put the server name, IP address, 
  and the port number.
  Use the default port number, 31257.
- Enjoy!


## How to contribute

Bug reports and pull requests are always welcome.


## FAQ

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
   but not both image and ZIP files.  


## License

Comix-server is free software licensed under [GNU GPLv3](http://www.gnu.org/licenses/gpl.txt). 
Everyone is permitted to copy, modify, and redistribute it.
