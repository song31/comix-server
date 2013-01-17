PHP-based AirComix Server

This document assumes that the comix server runs on a Synology NAS.
However, the server can run on any platform where Apache HTTP Server
exists because it only uses PHP and Apache HTTP server's configuration.


How to install
==============
- Log in the Synology DSM and make a shared folder, for example, named
  as "manga". This directory will be your manga directory.
- Enable ssh.
- Copy all php files to /var/services/web (Default DocumentRoot for Apache).
- Copy conf/httpd.conf-comix to /usr/syno/apache/conf/.
- Add a include directive, "Include /usr/syno/apache/conf/httpd.conf-comix", 
  without quotes, at the end of /usr/syno/apache/conf/httpd.conf and 
  /usr/syno/apache/conf/httpd.conf-user files. 
- Add the manga directory's path to the open_basedir variable in
  /usr/syno/etc/php/user-setting.ini.
- Reboot Synology server.


How to use
==========
- Copy your manga collection to the manga directory.
- Start AirComix App and add Synology server. Use the default port, 31251.
- Enjoy!


FAQ
===
Q) Do I need to uncompress ZIP files?
A) No. Like the Windows version, the server supports ZIP files.
   Of course, you can copy image files such as JPG and GIF to the
   manga directory.

Q) How can I change the port number?
A) See /usr/syno/apache/conf/httpd.conf-comix.

Q) How can I change the manga directory?
A) See handler.php. You need to modify handler.php, index.php, and
   httpd.conf-comix.

Q) Does the server support password protection?
A) No, current version does not support any authentication mechanism.
   We strongly recommend you run run the comix server in a private network.
   If you run the server on a public network, anybody can see the content.

Q) Does the server support other archive formats such as RAR or CBR?
A) No. Current version only supports ZIP (or CBZ).

