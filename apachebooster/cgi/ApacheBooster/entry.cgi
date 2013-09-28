#!/usr/local/cpanel/3rdparty/bin/perl
use lib '/usr/local/cpanel';
use Whostmgr::ACLS                      ();
Whostmgr::ACLS::init_acls();



if (-e "/usr/local/cpanel/bin/register_appconfig") {
        $script = "entry.cgi";
        $images = "ApacheBooster";
} else {
        $script = "addon_ApacheBooster.cgi";
        $images = "ApacheBooster";
}


print "Content-type: text/html\r\n\r\n";

if (!Whostmgr::ACLS::hasroot()) {
	print "You do not have access to this plugin.\n";
	exit();
}

print "<meta http-equiv=\"refresh\" content=\"0;url=index.html\"/>" ;
1;
