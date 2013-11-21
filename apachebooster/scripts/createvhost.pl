#!/usr/local/cpanel/3rdparty/bin/perl

BEGIN { unshift @INC, '/usr/local/cpanel', '/scripts/'; }

use Cpanel::ApacheBooster       ();
use Cpanel::DIp         	();
use Cpanel::WildcardDomain	();
use Data::Dumper;


my $main_ip 	= Cpanel::DIp::getmainip();

my $domain_name = $ARGV[0];
my $vhost_dir   = '/usr/local/nginx/vhost';

mkdir($vhost_dir) if !-d $vhost_dir;

if (not $domain_name) {
  Build_All();
} else {
  make_single_vhost($domain_name);
}


sub Build_All {
   my $domain_hash = Cpanel::ApacheBooster::domain_userdata();
   if($domain_hash->{status}) {
    foreach my $acct (keys(%{$domain_hash->{userdata}})) {
      my $IP_PORT = $domain_hash->{userdata}->{$acct}->{ip};
      if ((not $IP_PORT) || ($main_ip eq $IP_PORT)) {
	$IP_PORT = '80';
      }
      else {
	$IP_PORT = $IP_PORT . ':80';
      }
      if (Cpanel::WildcardDomain::is_wildcard_domain($domain_hash->{userdata}->{$acct}->{domain})) {
	$domain_hash->{userdata}->{$acct}->{domain_alias} = $domain_hash->{userdata}->{$acct}->{domain};
	$domain_hash->{userdata}->{$acct}->{domain}	  = Cpanel::WildcardDomain::encode_wildcard_domain($domain_hash->{userdata}->{$acct}->{domain});
      }
      vhost_template($IP_PORT, 
	    $domain_hash->{userdata}->{$acct}->{domain}, 
	    $domain_hash->{userdata}->{$acct}->{domain_alias},
	    $domain_hash->{userdata}->{$acct}->{documentroot},
	    $domain_hash->{userdata}->{$acct}->{ip});
    }
   } else {
      print "Unable to retrive domain's userdata\n";
   }
}



sub make_single_vhost {
  my $domain_name = shift;
  if ($domain_name =~ ".lock" ) {
    $domain_name =~ s/\.\w{4}$//;
    $domain_name = Cpanel::ApacheBooster::get_domain_by_username($domain_name); 
  } 
  elsif ($domain_name =~ /^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,4}$/i) {
    $domain_name = $domain_name;
  }
  elsif ( -f  '/var/cpanel/users/' . $domain_name ) {
    $domain_name = Cpanel::ApacheBooster::get_domain_by_username($domain_name);
  }
  elsif (Cpanel::WildcardDomain::is_wildcard_domain($domain_name)) {
    $domain_name = $domain_name; 
  }
  else {
    if ( -f  '/var/cpanel/users/' . $domain_name ) {
      $domain_name = Cpanel::ApacheBooster::get_domain_by_username($domain_name);
    }
  }
  
  my $domain_hash = Cpanel::ApacheBooster::single_domain_hash($domain_name);
  my $IP_PORT 	  = $domain_hash->{ip};
  if ((not $IP_PORT) || ($main_ip eq $IP_PORT)) {
    $IP_PORT = '80';
  }
  else {
    $IP_PORT = $IP_PORT . ':80';
  }
  if (Cpanel::WildcardDomain::is_wildcard_domain($domain_hash->{domain})) {
    $domain_hash->{domain_alias} = $domain_hash->{domain};
    $domain_hash->{domain}	 = Cpanel::WildcardDomain::encode_wildcard_domain($domain_hash->{domain});
  }
  vhost_template($IP_PORT,
      $domain_hash->{domain},
      $domain_hash->{domain_alias},
      $domain_hash->{documentroot},
      $domain_hash->{ip});
}

sub vhost_template {
    my ($listen, $main_domain, $domain_alias, $document_root, $domain_ip) = @_;
    my $conf = <<CONFIG;
server {
   access_log off;
   error_log  logs/vhost-error_log warn;
   listen $listen;
   server_name $main_domain $domain_alias;
   access_log /usr/local/apache/domlogs/$main_domain-bytes_log bytes_log;
   access_log /usr/local/apache/domlogs/$main_domain combined;
   root $document_root;
   location / {
   	location ~.*\.(3gp|gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|html|htm|txt|js|css|exe|zip|tar|rar|gz|tgz|bz2|uha|7z|doc|docx|xls|xlsx|pdf|iso|woff|ttf|svg|eot)\$ {
      	   expires 7d; #Comment this out if you're using the apache backend cache-control/expires headers.
           try_files \$uri \@backend;
   	}
        error_page 405 = \@backend;
        error_page  500 = \@custom;
        add_header X-Cache "HIT from Backend";
        proxy_pass http://$domain_ip:8082;
        include proxy.inc;
   }
   location \@backend {
        internal;
        proxy_pass http://$domain_ip:8082;
        include proxy.inc;
   }
   location \@custom  {
        internal;
        proxy_pass http://$domain_ip:8082;
        include proxy.inc;
   }
   location ~ .*\.(php|jsp|cgi|pl|py)?\$ {
        proxy_pass http://$domain_ip:8082;
        include proxy.inc;
   }
   location ~ /\.ht {
        deny all;
   }
}

CONFIG
  if (open(my $file, '>/usr/local/nginx/vhost/' . $main_domain . ".conf")) {
    print($file $conf);
    close $file;
  } else {
    print "Unable to create virtual host entry for $main_domain\n";
  }
}

