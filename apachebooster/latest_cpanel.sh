if [ -e "/usr/local/cpanel/bin/register_appconfig" ]; then
    /bin/cp -af /usr/local/cpanel/whostmgr/docroot/cgi/ApacheBooster/Driver/ApacheBooster /usr/local/cpanel/Cpanel/Config/ConfigObj/Driver/
    /bin/cp -af /usr/local/cpanel/whostmgr/docroot/cgi/ApacheBooster/Driver/ApacheBooster.pm /usr/local/cpanel/Cpanel/Config/ConfigObj/Driver/
    /bin/rm -f /var/cpanel/dynamicaclitems.cache

    /usr/local/cpanel/bin/register_appconfig /usr/local/cpanel/whostmgr/docroot/cgi/ApacheBooster/Driver/ApacheBooster.conf
    /bin/rm -f /usr/local/cpanel/whostmgr/docroot/cgi/addon_ApacheBooster.cgi
else
    chmod -v 700 /usr/local/cpanel/whostmgr/docroot/cgi/addon_ApacheBooster.cgi
    if [ ! -d "/var/cpanel/apps" ]; then
        mkdir /var/cpanel/apps
        chmod 755 /var/cpanel/apps
    fi
     /usr/local/cpanel/whostmgr/docroot/cgi/ApacheBooster/Driver/ApacheBooster.conf_old  /var/cpanel/apps/ApacheBooster.conf
     chmod 600 /var/cpanel/apps/ApacheBooster.conf
fi 
