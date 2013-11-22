#!/usr/bin/perl
#credit to CSF TEAM(COPIED FROM CSF AUTO SCRIPT)
use Fcntl qw(:DEFAULT :flock);
use IPC::Open3;

if ( ! -e "/etc/csf/csf.conf" ) {
  print "CSF Not Exists";
  exit 1;
 }

my $apache_port ="82";
my $varnish_port ="8082";
my $varnishad_port ="6082";
my $ports = "$apache_port" . ",$varnish_port" . ",$varnishad_port";
&loadcsfconfig;
$config{TCP_IN} =~ s/\s//g;
foreach my $port (split(/\,/,$config{TCP_IN})) 
{
  if ($port eq "82") 
  {
    $found_port = 1;
  }
}

if (! $found_port) 
{
 $config{TCP_IN} .= ",$ports";
 open (IN, "</etc/csf/csf.conf") or die $!;
  flock (IN, LOCK_SH) or die $!;
  my @config = <IN>;
 close (IN);
 chomp @config;
 open (OUT, ">/etc/csf/csf.conf") or die $!;
  flock (OUT, LOCK_EX) or die $!;
  foreach my $line (@config) 
  {
    if ($line =~ /^TCP_IN/) 
    {
      print OUT "TCP_IN = \"$config{TCP_IN}\"\n";
    } 
    else 
    {
       print OUT $line."\n";
    }
  }
 close OUT;
}
system("/etc/init.d/csf restart");
sub loadcsfconfig {
        open (IN, "</etc/csf/csf.conf") or die $!;
        flock (IN, LOCK_SH) or die $!;
        my @config = <IN>;
        close (IN);
        chomp @config;

        foreach my $line (@config) {
                if ($line =~ /^\#/) {next}
                if ($line !~ /=/) {next}
                my ($name,$value) = split (/=/,$line,2);
                $name =~ s/\s//g;
                if ($value =~ /\"(.*)\"/) {
                        $value = $1;
                } else {
                        die "Invalid configuration line";
                }
                $config{$name} = $value;
                $configsetting{$name} = 1;
        }
}

