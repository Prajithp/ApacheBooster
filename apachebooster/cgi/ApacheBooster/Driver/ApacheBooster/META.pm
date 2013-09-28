package Cpanel::Config::ConfigObj::Driver::ApacheBooster::META;

use strict;

use Cpanel::Config::ConfigObj::Driver::ApacheBooster();

sub meta_version {
    return 1;
}

sub get_driver_name {
    return 'ApacheBooster_driver';
}

sub content {
    my ($locale_handle) = @_;

    my $content = {
        'vendor' => 'Prajith',
        'url'    => 'www.prajith.in',
        'name'   => {
            'short'  => 'ApacheBooster Driver',
            'long'   => 'ApacheBooster Driver',
            'driver' => get_driver_name(),
        },
        'since'    => 'cPanel 11.38.1',
        'abstract' => "A ApacheBooster Driver",
        'version'  => $Cpanel::Config::ConfigObj::Driver::ApacheBooster::VERSION,
    };

    if ($locale_handle) {
        $content->{'abstract'} = $locale_handle->maketext("ApacheBooster driver");
    }

    return $content;
}

sub showcase {
    return;
}
1;
