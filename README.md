comix-server
============

Comix-server is a PHP-based AirComix Server acting just as the Windows
version. Originally it was written to run on the Synology NAS. However,
it can run on any platforms where Apache HTTP Server runs, such as
Ubuntu Linux or OS X.

Comix-server is only compatible with **iOS AirComix** app.


## How to install

```docker run -p31257:31257 -v<host comix dir>:/volume/manga -v<host .htpasswd dir>:/var/www/auth tee0125/aircomix-server```

default auth information is AirComix // 1234

## License

Comix-server is free software licensed under [GNU GPLv3](http://www.gnu.org/licenses/gpl.txt). 
Everyone is permitted to copy, modify, and redistribute it.
