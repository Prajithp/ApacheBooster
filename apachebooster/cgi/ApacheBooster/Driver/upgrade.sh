#!/bin/sh

if [ -e "/usr/local/cpanel/bin/register_appconfig" ]; then
    if [ -e "/usr/local/cpanel/whostmgr/docroot/cgi/addon_ApacheBooster.cgi" -o  -f "/usr/local/cpanel/whostmgr/docroot/cgi/addon_nginx.cgi" ]; then
        /bin/cp -af /usr/local/cpanel/whostmgr/docroot/cgi/ApacheBooster/Driver/ApacheBooster /usr/local/cpanel/Cpanel/Config/ConfigObj/Driver/
         /bin/cp -af /usr/local/cpanel/whostmgr/docroot/cgi/ApacheBooster/Driver/ApacheBooster.pm /usr/local/cpanel/Cpanel/Config/ConfigObj/Driver/
        /bin/rm -f /var/cpanel/dynamicaclitems.cache
        /usr/local/cpanel/bin/register_appconfig /usr/local/cpanel/whostmgr/docroot/cgi/ApacheBooster/Driver/ApacheBooster.conf
        if [ -f "/usr/local/cpanel/whostmgr/docroot/cgi/addon_ApacheBooster.cgi" ]; then
           /bin/rm -f /usr/local/cpanel/whostmgr/docroot/cgi/addon_ApacheBooster.cgi
        fi
        if [ -f "/usr/local/cpanel/whostmgr/docroot/cgi/addon_nginx.cgi" ]; then
           /bin/rm -Rf /usr/local/cpanel/whostmgr/docroot/cgi/
        fi
    fi
fi
