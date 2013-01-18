Comix-server is a PHP-based AirComix Server acting just as the Windows
version.  Originally it was made to run on the Synology NAS.  However,
it can run on any platform where Apache HTTP Server exists, such as
Ubuntu Linux or OSX.


## How to download 

Go to http://song31.github.com/comix-server/ and click the tar.gz or
zip folder icon in the page.


## How to install

You can find a step-by-step guide from
https://github.com/song31/comix-server/wiki/Step-by-Step-Configuration-Guide  

In short:
- Log in Synology DSM and make a shared folder, for example, named
  as "manga". This directory will be your manga directory.
- Enable ssh.
- Unzip the downloaded file and copy all to "web" folder (/var/services/web, default DocumentRoot).
- Connect to Synology server using ssh and do the remaining steps.
- Copy conf/httpd.conf-comix to /usr/syno/apache/conf/.
- Add the following line, "Include /usr/syno/apache/conf/httpd.conf-comix", 
  without quotes, at the end of /usr/syno/apache/conf/httpd.conf and 
  /usr/syno/apache/conf/httpd.conf-user files. 
- Add the manga directory's path to the open_basedir variable in
  /usr/syno/etc/php/user-setting.ini.
- Reboot Synology server.


## How to run

The Apache process automatically starts and is always running on Synlogy server.  


## How to use

- Copy your manga collection to the manga directory.
- Start AirComix app and add your Synology server. 
  Use the default port, 31251.
- Enjoy!


## FAQ

Q) Do I need to uncompress ZIP files?  
A) No. Like the Windows version, the server supports ZIP files.
   Of course, you can copy image files in JPG or GIF format to the
   manga directory.

Q) How can I change the port number?  
A) See /usr/syno/apache/conf/httpd.conf-comix.

Q) How can I change the manga directory?  
A) See handler.php. You need to modify handler.php, index.php, and
   httpd.conf-comix.

Q) Does the server support other archive formats such as RAR or CBR?  
A) No. Current version only supports ZIP (or CBZ).

Q) Does the server support password protection?  
A) Yes, using Apache's basic authentication mechanism. Refer to
   http://www.cs.duke.edu/csl/faqs/web/basic-auth to know how to
   configure it. Note that the user name should be AirComix (case
   sensitve) and .htaccess file should be in /var/services/web where
   handler.php exists. If there is no htpasswd util in your system, you can
   create the password file on other Linux/OSX machines and copy it to
   your system.

## How to contribute

But reports and pull requests are always welcomed.

