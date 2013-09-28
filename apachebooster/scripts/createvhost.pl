#!/bin/sh
eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
  if 0;

#!/usr/bin/perl
BEGIN { unshift @INC, '/usr/local/cpanel', '/scripts/'; }

use ApacheBooster;
use Cpanel::DIp         ();
my $mainip = Cpanel::DIp::getmainip();
my $mydomain = $ARGV[0];

if (! $mydomain) {
   &create_ini_file();
   my $config_file = "/tmp/apachebooster_ini";
   my $config = &ReadConfig($config_file);

   open (FILE, "</tmp/apachebooster_ini_tmp") or die $!;
       while ($listdomain = <FILE>) {
          chomp $listdomain;
          if ( $config->{"$listdomain"}->{'IP'} eq "$mainip" ) {
           $IPPORT = $mainip . ":80";
} elsif ( $config->{"$listdomain"}->{'IP'} eq "" ) {
         $IPPORT = $mainip . ":80";
} else {
        $IPPORT = $config->{"$listdomain"}->{'IP'} . ":80";
 }
    if ( !-d "/usr/local/nginx/vhost/" ) {
           mkdir("/usr/local/nginx/vhost/");
  }
  open($file, ">/usr/local/nginx/vhost/" . $config->{"$listdomain"}->{'DOMAIN'} . ".conf");
    my $conf = <<CONFIG;
server {
          access_log off;
          error_log  logs/vhost-error_log warn;
          listen $IPPORT;
          server_name $config->{"$listdomain"}->{'DOMAIN'}  $config->{"$listdomain"}->{'ALIAS'};
          root $config->{"$listdomain"}->{'DOCUMENTROOT'};
          location / {
          location ~.*\.(3gp|gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|html|htm|txt|js|css|exe|zip|tar|rar|gz|tgz|bz2|uha|7z|doc|docx|xls|xlsx|pdf|iso|woff|ttf|svg|eot)\$ {
             expires 7d; #Comment this out if you're using the apache backend cache-control/expires headers.
             try_files \$uri \@backend;
          }
             error_page 405 = \@backend;
             error_page  500 = \@custom;
             add_header X-Cache "HIT from Backend";
             proxy_pass http://$config->{"$listdomain"}->{'IP'}:8082;
             include proxy.inc;
          }
          location \@backend {
             internal;
             proxy_pass http://$config->{"$listdomain"}->{'IP'}:8082;
             include proxy.inc;
          }
          location \@custom  {
             internal;
             proxy_pass http://$config->{"$listdomain"}->{'IP'}:8082;
             include proxy.inc;
          }

          location ~ .*\.(php|jsp|cgi|pl|py)?\$ {
             proxy_pass http://$config->{"$listdomain"}->{'IP'}:8082;
             include proxy.inc;
          }
          location ~ /\.ht {
             deny all;
          }
        }

CONFIG
  print($file $conf);

  close $file;
  }
close FILE;
} else {
       if ( $mydomain =~".lock" ) {
                  $logger->info("testesteestest $mydomain");
                    exit;
        } else {
       if ($mydomain =~/^((([a-z]|[0-9]|\-)+)\.)+([a-z])+$/i) {
             $mydomains=$mydomain;
   } else {
            if ( -f "/var/cpanel/users/" . "$mydomain" ) {
            $mydomains=&getusername($mydomain);
   } else {
              die "syntax malformed";
  }
 }
}
    &create_S_Domain("$mydomains");
  my $config_file = "/tmp/apachebooster_ini";
   my $config = &ReadConfig($config_file);
   my $listdomain = $mydomains;
if ( $config->{"$listdomain"}->{'USER'} ) {
 if ( $config->{"$listdomain"}->{'IP'} eq "$mainip" ) {
    $IPPORT = $mainip . ":80";
  } elsif ( $config->{"$listdomain"}->{'IP'} eq "" ) {
         $IPPORT = $mainip . ":80";
  } else {
        $IPPORT = $config->{"$listdomain"}->{'IP'} . ":80";
 }
  if (!-d "/usr/local/nginx/vhost/" ) {
           mkdir("/usr/local/nginx/vhost/");
  }
  open($file, ">/usr/local/nginx/vhost/" . $config->{"$listdomain"}->{'DOMAIN'} . ".conf");
  my $conf = <<CONFIG;
server {
          access_log off;
          error_log  logs/vhost-error_log warn;
          listen $IPPORT;
          server_name $config->{"$listdomain"}->{'DOMAIN'}  $config->{"$listdomain"}->{'ALIAS'};
          root $config->{"$listdomain"}->{'DOCUMENTROOT'};
          location / {
          location ~.*\.(3gp|gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|html|htm|txt|js|css|exe|zip|tar|rar|gz|tgz|bz2|uha|7z|doc|docx|xls|xlsx|pdf|iso|woff|ttf|svg|eot)\$ {
             expires 7d; #Comment this out if you're using the apache backend cache-control/expires headers.
             try_files \$uri \@backend;
          }
             error_page 405 = \@backend;
             error_page  500 = \@custom;
             add_header X-Cache "HIT from Backend";
             proxy_pass http://$config->{"$listdomain"}->{'IP'}:8082;
             include proxy.inc;
          }
          location \@backend {
             internal;
             proxy_pass http://$config->{"$listdomain"}->{'IP'}:8082;
             include proxy.inc;
          }
          location \@custom  {
             internal;
             proxy_pass http://$config->{"$listdomain"}->{'IP'}:8082;
             include proxy.inc;
          }

          location ~ .*\.(php|jsp|cgi|pl|py)?\$ {
             proxy_pass http://$config->{"$listdomain"}->{'IP'}:8082;
             include proxy.inc;
          }
          location ~ /\.ht {
             deny all;
          }
        }

CONFIG
  print($file $conf);

  close $file;
 }

}
