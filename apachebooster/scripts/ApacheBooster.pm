#!/usr/local/cpanel/3rdparty/bin/perl
package ApacheBooster;

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
use vars qw(@ISA @EXPORT $VERSION);    # why is this use()ing vars, for older perl's w/out our() ??
require Exporter;                                                                                                                                                       
                                                                                                                                                                        
@ISA     = qw(Exporter);
@EXPORT  = qw(create_ini_file ReadConfig create_S_Domain getusername liveapi);
$VERSION = '0.0.1';

sub  create_ini_file 
{
  if ( -e "/tmp/createvhosttmp" ) 
  {
    unlink "/tmp/createvhosttmp";
  } 
  if ( -e  "/tmp/apachebooster_ini_tmp" ) 
  {
    unlink "/tmp/apachebooster_ini_tmp";
  }
  if ( -e "/tmp/apachebooster_ini" ) 
  {
    unlink "/tmp/apachebooster_ini";
  }
  open(FILE, ">>", "/tmp/createvhosttmp") or die $!;
  foreach my $email(liveapi(listaccts)->getElementsByTagName('acct'))
  {
    my @avalue =  $email->getElementsByTagName('user')->item(0)->getFirstChild->getNodeValue."\n";
    print FILE "@avalue";
  }
  close FILE;  
  my $line;
  open(FILE, "/tmp/createvhosttmp");
  open (MYFILE, '>>/tmp/apachebooster_ini_tmp');
  while ($line = <FILE>) 
  {
    chomp $line;
    my $user = "$line\n";
    my $inside = 0;
    my $data = '';
    chomp $user;
    open(DATA,"</var/cpanel/userdata/$user/main") or die "Could not open input: $!\n";
    while (<DATA>) 
    {
      $inside = 1 if /sub_domains/;
      last if /^$/ and $inside;
      my  $string = $_ if $inside;
      my $array = $string;
      $array =~ s/sub_domains://g;
      substr($array,0,4)="";
      print MYFILE "$array";
    }
    close DATA;
    foreach my $data  (liveapi("accountsummary?user=$user")->getElementsByTagName('acct')) 
    {
      $maindomain =  $data->getElementsByTagName('domain')->item(0)->getFirstChild->getNodeValue;
    }
    print MYFILE "$maindomain\n";

  }
  close(FILE);
  close (MYFILE);
  open(FILE13, "/tmp/apachebooster_ini_tmp");
  while ($line1 = <FILE13>) 
  {
    chomp $line1;
    my $domain = $line1;
    foreach  my $data  (liveapi("domainuserdata?domain=$domain")->getElementsByTagName('userdata')) 
    {
      my $documentroot =  $data->getElementsByTagName('documentroot')->item(0)->getFirstChild->getNodeValue;
      my $ip =  $data->getElementsByTagName('ip')->item(0)->getFirstChild->getNodeValue;
      my $user = $data->getElementsByTagName('user')->item(0)->getFirstChild->getNodeValue;
      my $value = $data->getElementsByTagName('serveralias')->item(0);
      my  $alias = $data->getElementsByTagName('serveralias')->item(0)->getFirstChild->getNodeValue;
      if (($user && $value ne "")) 
      {
        open (FILE2, '>>/tmp/apachebooster_ini');
        print FILE2 "[$domain]\n";
        print FILE2 "DOMAIN:$domain\n";
        print FILE2 "ALIAS:$alias\n";
        print  FILE2 "USER:$user\n";
        print FILE2  "DOCUMENTROOT:$documentroot\n";
        print FILE2  "IP:$ip\n";
        close FILE2;
      } 
      else 
      {
        open (FILE2, '>>/tmp/apachebooster_ini');
        print FILE2 "[$domain]\n";
        print FILE2 "DOMAIN:$domain\n";
        print FILE2 "ALIAS:$alias\n";
        print  FILE2 "USER:$user\n";
        print FILE2  "DOCUMENTROOT:$documentroot\n";
        print FILE2  "IP:$ip\n";
        close FILE2;
      }
    }
  }
  close FILE13;
}

sub create_S_Domain
{
  if ( -e "/tmp/apachebooster_ini" ) 
  {
    unlink "/tmp/apachebooster_ini";
  } 
  my $domain = shift;
  foreach  my $data  (liveapi("domainuserdata?domain=$domain")->getElementsByTagName('userdata')) {
    my $documentroot =  $data->getElementsByTagName('documentroot')->item(0)->getFirstChild->getNodeValue;
    my $ip =  $data->getElementsByTagName('ip')->item(0)->getFirstChild->getNodeValue;
    my $user = $data->getElementsByTagName('user')->item(0)->getFirstChild->getNodeValue;
    my $value = $data->getElementsByTagName('serveralias')->item(0);
    my $alias = $data->getElementsByTagName('serveralias')->item(0)->getFirstChild->getNodeValue;
    if (($user && $value ne "")) 
    {
      open (FILE2, '>>/tmp/apachebooster_ini');
      print FILE2 "[$domain]\n";
      print FILE2 "DOMAIN:$domain\n";
      print FILE2 "ALIAS:$alias\n";
      print  FILE2 "USER:$user\n";
      print FILE2  "DOCUMENTROOT:$documentroot\n";
      print FILE2  "IP:$ip\n";
      close FILE2;
    } 
    else 
    {
      open (FILE2, '>>/tmp/apachebooster_ini');
      print FILE2 "[$domain]\n";
      print FILE2 "DOMAIN:$domain\n";
      print FILE2 "ALIAS:$alias\n";
      print  FILE2 "USER:$user\n";
      print FILE2  "DOCUMENTROOT:$documentroot\n";
      print FILE2  "IP:$ip\n";
      close FILE2;
    }
  }
}

sub ReadConfig 
{
  my $config;
  $config_file = shift;
  open(CONF,"<$config_file") || die("Unable to read configuration file: $config_file\n\n");
  my $section;
  while(<CONF>) 
  {
    chomp($_);
    s/\r//g;        ## Remove DOS EOL Symbols
    s/\#.*//g;      ## Remove comments
    s/\;.*//g;   ## Remove comments
    next if(! $_);
    if (substr($_,0,1) eq "[") 
    {
      $section = $_;
      $section =~ s/\[//g;
      $section =~ s/\]//g;
      next;
    }
    next if($_ !~ m/:/);
    if($section) 
    {
      my ($item,$value) = split(':',$_);
      ## Remove un-necessary speces
      $item =~ s/ +$//g;
      $value =~ s/^ $//g;
      $value =~ s/^\s+//;
      $config->{$section}->{$item} = $value;
    }
  }
  close(CONF);
  return $config;
}


sub usernamedetails 
{
  unlink "/tmp/createvhosttmp";
  open FILE, ">>/tmp/createvhosttmp" or die $!;
  foreach my $email(liveapi(listaccts)->getElementsByTagName('acct'))
  {
    my $avalue =  $email->getElementsByTagName('user')->item(0)->getFirstChild->getNodeValue."\n";
    print FILE "$avalue";
  }
  close FILE;
  my $line;
  open(FILE, "/tmp/createvhosttmp");
  while ($line = <FILE>) 
  {
    chomp $line;
    getuserdetails($line);
  }
  close FILE;
}


sub getuserdetails 
{
  my $user = shift;
  my $inside = 0;
  my $data = '';
  open(DATA,"</var/cpanel/userdata/$user/main") or die "Could not open input: $!\n";
  while (<DATA>) 
  {
    $inside = 1 if /sub_domains/;
    last if /^$/ and $inside;
    my  $string = $_ if $inside;
    my $array = $string;
    $array =~ s/sub_domains://g;
    substr($array,0,4)="";
    $subdomain = $array;
  }
  close DATA;
  foreach my $data  (liveapi("accountsummary?user=$user")->getElementsByTagName('acct')) 
  {
    $maindomain =  $data->getElementsByTagName('domain')->item(0)->getFirstChild->getNodeValue;
  }      
  return ("$maindomain\n", "$subdomain\n");
}



sub getusername 
{
  my $domain = shift;
  if (not $domain)
  {
     return 0;
  }
  foreach my $data  (liveapi("accountsummary?user=$domain")->getElementsByTagName('acct'))
  {
    $user_name =  $data->getElementsByTagName('domain')->item(0)->getFirstChild->getNodeValue;
  }    
  return $user_name;
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
  return $accesshash1;
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
  my $parser = XML::DOM::Parser->new();
  my $doc = $parser->parse($xml_string);
  return $doc;
}

