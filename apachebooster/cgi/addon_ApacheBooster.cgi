#!/usr/local/cpanel/3rdparty/bin/perl
#WHMADDON::ApacheBooster
####################################
# start main

use lib '/usr/local/cpanel';
use Whostmgr::ACLS			();

Whostmgr::ACLS::init_acls();

print "Content-type: text/html\r\n\r\n";

if (!Whostmgr::ACLS::hasroot()) {
	print "You do not have access to this plugin.\n";
	exit();
}

print "<meta http-equiv=\"refresh\" content=\"0;url=ApacheBooster/index.html\"/>" ;

1;
