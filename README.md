Comix-server is a PHP-based AirComix Server acting just as the Windows
version.  Originally it was made to run on the Synology NAS.  However,
it can run on any platforms where Apache HTTP Server runs, such as
Ubuntu Linux or OSX.


## How to download

Go to http://song31.github.com/comix-server/ and click the tar.gz or
zip folder icons in the page.


## How to install

You can find a step-by-step guide at 
https://github.com/song31/comix-server/wiki/Step-by-Step-Configuration-Guide  

In short,
- Log in to the Synology DSM and make a shared folder, for example, named
  "manga". This directory will be your manga directory.
- Enable SSH.
- Unzip the downloaded file and copy all to the "web" folder (/var/services/web, default DocumentRoot).
- Connect to your Synology server using SSH and do the remaining steps.
- Copy conf/httpd.conf-comix to /usr/syno/apache/conf/.
- Add the following line, "Include /usr/syno/apache/conf/httpd.conf-comix", 
  without quotes of course, at the end of /usr/syno/apache/conf/httpd.conf and 
  /usr/syno/apache/conf/httpd.conf-user. 
- Add the manga directory's path to the open_basedir variable in
  /usr/syno/etc/php/user-setting.ini.
- You might need to modify files to set up your manga directory. See handler.php for details. 
- Reboot the Synology server.


## How to run

The Apache HTTP process automatically starts and is always running on the Synology server.


## How to use

- Copy your comic collection to the manga directory.
- Start AirComix app on your iPhone/iPad and add your Synology server. 
  Use the default port number, 31251.
- Enjoy!


## FAQ

Q) Do I need to uncompress ZIP files?  
A) No. Like Windows version, comix-server supports ZIP files.

Q) How can I change the port number?  
A) See /usr/syno/apache/conf/httpd.conf-comix.

Q) How can I change the manga directory?  
A) See handler.php. You need to modify handler.php, index.php, user-setting.ini, 
   and httpd.conf-comix.

Q) Does comix-server support other archive formats such as RAR or CBR?  
A) No. Current version only supports ZIP (or CBZ).

Q) Does comix-server support password protection?  
A) Yes, using Apache's basic authentication mechanism. Refer to
   http://www.cs.duke.edu/csl/faqs/web/basic-auth to know how to
   configure it. Note that the user name should be AirComix (case
   sensitve) and .htaccess file should be in /var/services/web where
   handler.php exists. If there is no htpasswd util in your system, you can
   create the password file on other machines and copy it to
   your system.


## How to contribute

Bug reports and pull requests are always welcome.

