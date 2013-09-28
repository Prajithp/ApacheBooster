#!/bin/sh
eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
  if 0;

#!/usr/bin/perl
# apachebooster - whmapi.pl                           Copyright(c) 2011 Ndimensionz, Inc.
#                                                           All rights Reserved.
# prajithpalakkuda@gmail.com                                       http://ndimensionz.com http://esupports.net
# This code is subject to the Ndimensionz  license. Unauthorized copying is prohibited

BEGIN{ unshift(@INC, '/usr/local/cpanel'); }

use Cpanel::PublicAPI ();
use Data::Dumper      ();
use IPC::Open3        ();
use JSON::Syck        ();
use XML::DOM;
use XML::Simple;
use Getopt::Long;


my $gd = '';
my $sa = '';
my $gu = '';

if (getpwuid( $< ) ne 'root') {
        print "Script needs root privileges \n";
        exit();
}

unless (GetOptions (
                'sa' => \$sa,
                'gd=s' => \$gd,
                'gu=s' => \$gu) or usage()) {    usage();}

if ($gd || $sa || $gu) {
      if ($gd) {
      getdomaindetails($gd);
     } elsif ($sa) {
    usernamedetails();
  } elsif ($gu) {
     getusername($gu);
   } else {
     usage();
}
} else {
     usage();
}


sub usage 
{
    print << "USAGE"

    usage: /scripts/whmapi.pl [--gd domain or user | --gu user| --sa]
USAGE
}
sub  getdomaindetails 
{
     my $domain = shift;
     foreach my $data  (liveapi("domainuserdata?domain=$domain")->getElementsByTagName('userdata')) {
       my $documentroot =  $data->getElementsByTagName('documentroot')->item(0)->getFirstChild->getNodeValue;
       my $ip =  $data->getElementsByTagName('ip')->item(0)->getFirstChild->getNodeValue;
       my $user = $data->getElementsByTagName('user')->item(0)->getFirstChild->getNodeValue;
       my $value = $data->getElementsByTagName('serveralias')->item(0);
       if ($value ne "") {
          print "ALIAS:" . $data->getElementsByTagName('serveralias')->item(0)->getFirstChild->getNodeValue . "\n";
        }         
       if ($user) {
           print "DOMAIN:$domain\n";
           print "USER:$user\n";
           print "DOCUMENTROOT:$documentroot\n";
           print "IP:$ip\n";
         }   
      }
}

sub usernamedetails 
{
     unlink "/tmp/createvhosttmp";
     foreach my $email(liveapi(listaccts)->getElementsByTagName('acct'))
       {
          my @avalue =  $email->getElementsByTagName('user')->item(0)->getFirstChild->getNodeValue."\n";
          open FILE, ">>/tmp/createvhosttmp" or die $!;
            print FILE "@avalue";
          close FILE;
       }   
     my $line;
     open(FILE, "/tmp/createvhosttmp");
        while ($line = <FILE>) {
           chomp $line;
           getuserdetails($line);
          }
        close FILE;
}


sub getuserdetails 
{
     my $domain = shift;
     my $inside = 0;
     my $data = '';
     open(DATA,"</var/cpanel/userdata/$domain/main") or die "Could not open input: $!\n";
        while (<DATA>) {
          $inside = 1 if /sub_domains/;
          last if /^$/ and $inside;
          my  $string = $_ if $inside;
          my $array = $string;
          $array =~ s/sub_domains://g;
          substr($array,0,4)="";
          print $array;
         }
     close DATA;
     foreach my $data  (liveapi("accountsummary?user=$domain")->getElementsByTagName('acct')) {
          print $data->getElementsByTagName('domain')->item(0)->getFirstChild->getNodeValue."\n";
     }      
}



sub getusername 
{
    my $domain = shift;
    foreach my $data  (liveapi("accountsummary?user=$domain")->getElementsByTagName('acct'))
     {
       print $data->getElementsByTagName('domain')->item(0)->getFirstChild->getNodeValue."\n";
     }    
}




sub accesshash 
{
    my $theHash;
    if ( !$ENV{'REMOTE_USER'} || $ENV{'REMOTE_USER'} eq 'root' ) 
     {
      $theHash = "/root/.accesshash";
     }  

   unless ( -f $theHash ) 
    {
     my $pid = IPC::Open3::open3( my $wh, my $rh, my $eh, '/usr/local/cpanel/whostmgr/bin/whostmgr setrhash' );

       waitpid( $pid, 0 );
   }   

   open( my $hash_fh, "<", "/root/.accesshash" ) || die "Cannot open access hash: " . $theHash;
     my $accesshash1 = do { local $/; <$hash_fh>; };
     close($hash_fh);
  $accesshash1 =~ s/\n//g;
  my $accesshash = $accesshash1;
}

sub liveapi 
{
  my $func = shift;
  my $publicAPI = Cpanel::PublicAPI->new(
            usessl     => 1,
            user       => root,
            accesshash => accesshash()
      );

  my $response = $publicAPI->whm_api( $func, $formdata, 'xml' );

  my $xml_string = $response;
  my $xml_hashref = XMLin($xml_string);
  my $parser=XML::DOM::Parser->new();
  my $doc=$parser->parse($xml_string);
  my $liveapi = $doc;
}
