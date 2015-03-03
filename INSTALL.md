# Step by Step Configuration Guide


## Overview

In comix-server, there are two important directories: the *manga* directory and the *web* directory. The *manga* directory is where your manga data will be stored. You will copy your manga collections in the ZIP files to the *manga* directory. In this guide, we assume that the path of your manga directory is /volume1/manga.

The *web* directory is where comix-server will be installed. The comix-server's PHP files, such as welcome.php, index.php, and handler.php, will be copied to the *web* directory during the configuration. The default path of the *web* directory is /var/services/web/comix-server.



## Synology DSM configuration

This guide is written based on Synology DSM version 4.1, but menus and features in other versions seem likely to be same.

- Log in to your Synology DSM using a web browser.

- Enable Web Station
    - In the DSM, go to Control Panel -> Web Services.
    - In the Web Applications panel, check Enable Web Station and press Apply.
    - In the PHP Settings panel, click the Select PHP extension button and 
      make sure both zip and zlib are checked in the PHP extension List popup.  

- Create your *manga* directory as a shared folder.
    - In the DSM, go to Control Panel -> Shared Folder -> Create.
    - In the Shared Folder Info panel, fill in the following fields and press OK.
        - Name: manga
        - Description: AirComix Manga Directory
    - Edit the privilege setting.

  After creating the shared folder, make sure that you can copy manga files to the *manga*
  directory using whatever protocol you want to use, such as SMB, AFP, FTP, or WebDAV.

- Enable SSH service for the installation procedure.
    - In the DSM, go to Control Panel -> Terminal.
    - In the Terminal Service Options panel, check Enable SSH service and press Apply.



## Installation using installer

- Download comix-server-master.zip using the following link: <https://github.com/song31/comix-server/archive/master.zip>.   

- Unzip the comix-server-master.zip you downloaded and copy install.sh and uninstall.sh to your *manga* directory using whatever protocol you like. You don't need to copy other files. The installer will download necessary files on the Synology server.  

- Connect to your Synology NAS as *root* using an SSH client such as 
  [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).   
  The password of the *root* account is same as the admin user's in DSM.

- In the shell, go to the *manga* directory and make sure install.sh is copied there.

  ```
  DiskStation> cd /volume1/manga
  DiskStation> ls install.sh
  ```

  The *manga* directory's path might be different in your system.
  **If it is not /volume1/manga, you should modify the *MANGA_DIR* variable in install.sh before running it.**

- Make install.sh executable.

  ```
  DiskStation> chmod 755 install.sh
  ```

- Run install.sh.

  ```
  DiskStation> ./install.sh
  ```

The installer does everything for you: detects DSM version to determine configuration file path, updates Apahe and PHP configuration, installs comix-server, and restarts Apache HTTP Server. Now you can add your comix-server in the AirComix app. Use **AirComix Server URL** and put the server name, IP address, and the port number on the app. The default port numer is 31257.


## Uninstallation using uninstaller

- Connect to the Synology server using SSH, got to your *manga* directory, and make sure uninstall.sh is copied there. 

  ```
  DiskStation> cd /volume1/manga
  DiskStation> ls uninstall.sh
  ```

  The *manga* directory's path might be different in your system.    
  If uninstall.sh does not exist there, follow the step 1 and 2 in the installation section.
   
- Make uninstall.sh executable.

  ```
  DiskStation> chmod 755 uninstall.sh
  ```

- Run uninstall.sh.

  ```
  DiskStation> ./uninstall.sh
  ```
  
The uninstaller removes only comix-server's files and configuration. **It does NOT delete the content of your manga directory.**


## Manual installation (optional)

This section describes how to install comix-server manually without using installer. **If you already installed comix-server using installer, skip this section.**   
Most of the Apache configuration will be done on the Linux shell so you need to prepare an SSH client to connect to your Synology server. Any command starting with "DistStation>" in this guide should be run on the shell in the Synology server. 

- Connect to your Synology NAS as *root* using an SSH client. The password of the *root* account is same as the admin user's in DSM.

- In the shell, create the *web* directory.

  ```
  DiskStation> mkdir -p /var/services/web/comix-server
  ```

- Download comix-server zip file using the following link: 
  <https://github.com/song31/comix-server/archive/master.zip> and unzip it.
    
- Copy the following comix-server files to the *web* directory using whatever protocol you like. If you use File Station, you can see the *web* directory under DiskStation->web->comix-server.
    - install.sh: installer
    - uninstall.sh: uninstaller
    - welcome.php: including welcome message
    - index.php: including the manga directory's name
    - handler.php: actual worker!
    - conf/httpd.conf-comix: an example of httpd configuration
    - conf/htaccess: an example of http authentication file  

- In the shell, copy conf/httpd.conf-comix to /usr/syno/apache/conf/.

  ```
  DiskStation> cp /var/services/web/comix-server/conf/httpd.conf-comix /usr/syno/apache/conf/httpd.conf-comix
  ```

- Open /usr/syno/apache/conf/httpd.conf-user using a text editor, I guess the only option is vi, and add the following line, "Include /usr/syno/apache/conf/httpd.conf-comix", at the end of the file. The httpd.conf-user file is a template for httpd.conf, which is the actual configuration file for Apache. The httpd.conf file is regenerated based on the template file whenever the Synology server boots up.

  ```
  DiskStation> cd /usr/syno/apache/conf   
  DiskStation> vi httpd.conf-user
  ```

  > \<VirtualHost \*:80\>  
  > Include /usr/syno/etc/sites-enabled-user/\*.conf  
  > \</VirtualHost\>
  >
  > **Include /usr/syno/apache/conf/httpd.conf-comix**  

- Also add the same line to /usr/syno/apache/conf/httpd.conf to apply it without rebooting.

- Open /usr/syno/etc/php/user-setting.ini and add the *web* and *manga* directory's full path at the end of the *open_basedir* variable. **Note that you should put a colon in front of each path**.    

  ```
  DiskStation> cd /usr/syno/etc/php
  DiskStation> vi user-setting.ini
  ```
	
  > open_basedir = xxxyyyyzzzz:/var/services/web/comix-server:/volume1/manga  

  Note that the *manga* directory's path, /volume1/manga, might be different in your server. Make sure you are entering the correct path. See Customization section if you have a different path.  

- Make sure your *manga* directory has the right Linux file permission so comix-server can access it.
  
  ```
  DiskStation> chmod 755 /volume1/manga

  ```

- Restart httpd to apply configuration change, or you can reboot the system using DSM menu.
    - Find httpd parent process's PID.  
        
      ```
      DiskStation> ps | grep HAVE_PHP  
      ```
        
      In the result, the first number followed by "root" is the PID like below.   
        
      ```
      10442 root     65032 S    /usr/syno/apache/bin/httpd -DHAVE_PHP   
      ```

    - Kill the process using the PID.  
        
      ```
      DiskStation> kill 10442
      ```

    - Restart the httpd process.  
        
      ```
      DiskStation> /usr/syno/apache/bin/httpd -DHAVE_PHP
      ```



## Authentication configuration (optional)

In order to enable the server-side password protection, you need to configure Apache basic authentication. This is optional, but if it is not turned on, anyone might be able see your manga collection. We highly recommend turning on this option unless you are running your server in a private network.

- Create a password file for the user *AirComix* (case sensitive) using the htpasswd command. Since the Synology server does not have htpasswd, **you need to do it on other machines which have one**. Typical Linux and OS X machines have it. On the terminal, run the following command. 

  ```
  # htpasswd -cb .htpasswd AirComix 1234
  ```

  The command creates a password file named *.htpasswd* under the current directory and adds a user *AirComix* with a password *1234*. You can use your own password, but **you cannot change the user name**.

- Copy the password file to the Synology server using SSH.

  ```
  # scp .htpasswd root@<your synology ip>:/var/services/
  ```

- Log in to the Synology server using SSH and make sure the password file is copied in the correct place.

  ```
  DiskStation> ls /var/services/.htpasswd
  ```

- Copy conf/htaccess to the *web* directory. **Note that the file name should start with dot**.

  ```
  DiskStation> cp /var/services/web/comix-server/conf/htaccess /var/services/web/comix-server/.htaccess
  ```

  Make sure the variable *AuthUserFile* in *.htaccess* points the correct path of *.htpasswd*.  

Now the server-side password is enabled. You need to enter the password (e.g., 1234) in the server configuration on the AirComix app.



## Customization

- To change your *manga* directory (or its path is not /volume1/manga), you need to modify 
  four files: handler.php, index.php, httpd.conf-comix, and user-setting.ini.  

  If your *manga* directory is /home/comix/my-manga-dir, the contents of these files should 
  look like below.  

  In /var/services/web/comix-server/handler.php,
  
  > $parent_path = **"/home/comix"**;
  

  In /var/services/web/comix-server/index.php,
  
  > $dir_name = **"my-manga-dir"**;
  

  In /usr/syno/etc/php/user-setting.ini,
  
  > open_base_dir = …:/home/comix/my-manga-dir

  In /usr/syno/apache/conf/httpd.conf-comix,
  
  > AliasMath ^/my-manga-dir(.*)$ /var/services/web/comix-server/handler.php
  

- To change your *web* directory where you install comix-server, (or its path is not /var/services/web/comix-server), follow the instruction below.

  - Create a new directory, for example, /comix-server.

    ```
    DiskStation> cd /
    DiskStation> mkdir comix-server
    ```

  - Copy comix-server's PHP files to the directory. Here, we assume that you already copied the PHP files to /var/services/web/comix-server before. Make sure there are index.php, handler.php, and welcome.php under /comix-server after copying them.

    ```
    DiskStation> cp /var/services/web/comix-server/*.php /comix-server/
    DiskStation> ls /comix-server/
    ```

  - Give the right permission on the PHP files so Apache process can access them.

    ```
    DiskStation> chmod 755 /comix-server
    DiskStation> chmod 644 /comix-server/*.php
    ```

  - Add your *web* directory to *open_base_dir* in user-setting.ini.

    In /usr/syno/etc/php/user-setting.ini,
    
    > open_base_dir = ...:/comix-server

  - Modify httpd.conf-comix like below. Make sure you are putting the correct path 
    in *DocumentRoot* and *AliasMatch*.

    ```
    Listen 31257
    <VirtualHost *:31257>
      DocumentRoot "/comix-server"
      AllowEncodedSlashes On
      DirectoryIndex index.php
      AliasMatch ^/welcome.102(.*)$ /comix-server/welcome.php
      AliasMatch ^/manga(.*)$ /comix-server/handler.php
    </VirtualHost>  
    ```

- To change port number, modify httpd.conf-comix. You need to change both *Listen* and *VirtualHost* directives in the file.

- To change the welcome message shown when you connect to the server, modify welcome.php. The welcome message is only shown when you use the older version of the AirComix app.

  

## Troubleshooting

1. If you cannot connect to comix-server or get "Can not connect to server" error message, check the following list.
    - Httpd processes. There should be a few "/usr/syno/apache/bin/httpd -DHAVE_PHP" processes running on the Synology server.
    - Correct port number.
    - Correct password, if server-side password is enabled.  

2. If Apache HTTP Server does not start after the installation, make sure there is only single "Include /usr/syno/apache/conf/httpd.conf-comix" line at the end of httpd.conf and httpd.conf-user.   
    
3. If you don't see your top manga directory when you connect to your comix-server, make sure you configured the correct *web* directory. The httpd.conf-comix and user-setting.ini file should have the correct path of the *web* directory. Also make sure there are index.php, welcome.php, and handler.php in the *web* directory.

    You can test comix-server using a web browser. Open a web browser and go to http://\<your synology ip\>:31257. The browser should display the name of your manga directory.  

4. If you don't see the list of directories and files after you click the *manga* directory, check the following list.
    - *Manga* directory configuration. See Customization section to know how to configure/change the *manga* directory.
    - Linux permission of the directories and files. Apache HTTP Server runs as nobody (or http) so all users should have execution permission (x) on all directories from root to any subdirectories under your manga directory. All users should also have read permission (r) on all your manga files. Change permission carefully using the chmod command on the shell. **Note that in DSM 5.x, default permision of shared directories is 000 so you need to run 'chmod 755 /volume1/manga' after creating your *manga* directory.**
    - PHP open_basedir configuration. By default, PHP can open files in any directories, but the access is limited to specific directories by setting the open_basedir variable. In Synology, you should add your *manga* directory in /usr/syno/etc/php/user-setting.ini because this limitation is on by default. In Linux, open_basedir is usually not set on and you don't need to add your directories in it. Refer to http://php.net/manual/en/ini.core.php for more information.

    You can test comix-server using a web browser. Open a web browser and go to http://\<your synology ip\>:31257/manga. The directories or files under your manga folder will show up in the browser. 

    Let's say we have a file, /volume1/manga/folder1/01.zip and 01.zip contains 01.jpg to 10.jpg. Requesting http://\<your synology ip\>:31257/manga will show folder1 in the browser and requesting http://\<your synology ip\>:31257/manga/folder1 will show 01.zip. Requesting http://\<your synology ip\>:31257/manga/folder1/01.zip will return the list of files in the ZIP file: 01.jpg to 10.jpg. Finally, requesting http://\<your synology ip\>:31257/manga/folder1/01.zip/01.jpg will display the actual image in the browser.

5. If you see "can't open xxxxx.zip" when you request a ZIP file from a web browser, check the *open_basedir* variable in the user-setting.ini file. Make sure you correctly add your *manga* directory in the list. Also check whether each path in the list is separated by colons.   

6. If you see the source code of PHP files in the browser, it is a typical problem when PHP execution is not configured correctly in Apache HTTP Server. There are plenty of documents about how to fix it in the Internet.

7. If you cannot see the content of ZIP files, but can see image files, your system does not have necessary PHP extensions for comix-server. Comix-server requires following PHP extensions: Zip (http://php.net/manual/en/book.zip.php), iconv (http://php.net/manual/en/book.iconv.php), and RAR (http://php.net/manual/en/book.rar.php). Consult their web pages above to install them.
