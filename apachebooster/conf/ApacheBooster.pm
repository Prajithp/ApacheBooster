package Cpanel::ApacheBooster;


use JSON 			();
use IPC::Open3 			();
use Cpanel::PublicAPI 		();
use Cpanel::YAML 		();
use Cpanel::LoadFile 		();
use Data::Dumper;






sub get_domain_by_username {
  my $user = shift;
  my $domain = undef;
  my $json_resp = liveapi_request('accountsummary?user=' . $user);
  if ($json_resp->{status}) {
    $domain = $json_resp->{acct}[0]->{domain};
  }
  return $domain;
}


sub single_domain_hash {
  my $domain = shift;
  my $return_hash;
  my $json_resp = liveapi_request('domainuserdata?domain=' . $domain);
  if ($json_resp->{result}[0]->{status}) {
     my $domain_alias = $json_resp->{userdata}->{serveralias} if(defined $json_resp->{userdata}->{serveralias});
     $return_hash = { 'domain' => $json_resp->{userdata}->{servername}, 
		      'ip' => $json_resp->{userdata}->{ip}, 
		      'user' => $json_resp->{userdata}->{user},
                      'documentroot' => $json_resp->{userdata}->{documentroot},
                      'domain_alias' => $domain_alias, 
                    };
  }
  return $return_hash;
}


sub domain_userdata {
  my $return_hash;
  my $domains = build_domain_list();
  if (scalar(@{$domains})) {
    foreach my $acct (@{$domains}) {
      my $json_resp = liveapi_request('domainuserdata?domain=' . $acct);
	if ($json_resp->{result}[0]->{status}) {
	  my $domain_alias = $json_resp->{userdata}->{serveralias} if(defined $json_resp->{userdata}->{serveralias});
          my $hash = { 	'domain' => $json_resp->{userdata}->{servername}, 
			'ip' => $json_resp->{userdata}->{ip}, 
			'user' => $json_resp->{userdata}->{user},
			'documentroot' => $json_resp->{userdata}->{documentroot},
			'domain_alias' => $domain_alias, 
		     };
          $return_hash->{userdata}->{$acct} = $hash;
      }
    }
    $return_hash->{status} = '1';
  } else {
    $return_hash->{status} = '0';
  }
  return $return_hash;
}


sub build_domain_list {
  my @domain_array;
  my @users_array;
  my $json_resp = liveapi_request(listaccts);
  foreach my $acct (@{$json_resp->{acct}}) {
    push(@domain_array, $acct->{domain});
    my $subdomain_hash = get_subdomain($acct->{user});
    foreach $sub_domain (@{$subdomain_hash}) {
      push(@domain_array, $sub_domain);
    }
  }
  return \@domain_array if scalar(@domain_array);
}


sub get_subdomain {
  my $user = shift;
  my $dump = Cpanel::LoadFile::loadfile("/var/cpanel/userdata/$user/main");
  my $yaml_parse  = Cpanel::YAML::Load($dump);
  return $yaml_parse->{sub_domains}; 
}


sub access_hash {
    my $theHash = "/root/.accesshash";
    unless ( -f $theHash ) {
    my $pid = IPC::Open3::open3( my $wh, my $rh, my $eh, '/usr/local/cpanel/whostmgr/bin/whostmgr setrhash' );
    waitpid( $pid, 0 );
    }
    open( my $hash_fh, "<", "/root/.accesshash" ) || die "Cannot open access hash: " . $theHash;
    my $accesshash = do { local $/; <$hash_fh>; };
    $accesshash =~ s/\n//g;
    return $accesshash;
}



sub liveapi_request {
  my ($func, $module, $user) = @_;
  my $accesshash = access_hash();
  my $username = 'root';
  my $publicAPI = Cpanel::PublicAPI->new(
            usessl => 0,
            user => $username,
            accesshash => $accesshash
          );
  my $response;
  if (defined $module && defined $func && defined $user){
    $response = $publicAPI->cpanel_api2_request('whostmgr', { 'module' => $module, 'func' => $func, user => $user, }, undef, 'json' );
  }
  else {
    $response = $publicAPI->whm_api( $func, undef, 'json' );
  }
  my $json_obj = JSON->new();
  my $json = $json_obj->allow_nonref->utf8->relaxed->decode( $response );
  return $json;
}
1;
