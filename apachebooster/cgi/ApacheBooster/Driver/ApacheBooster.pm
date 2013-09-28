package Cpanel::Config::ConfigObj::Driver::ApacheBooster;

use strict;


our @ISA = qw(Cpanel::Config::ConfigObj::Interface::Config::v1);    

our $VERSION = '1.0';

sub init {
    my $class        = shift;
    my $software_obj = shift;

    my $ApacheBooster_new = {
        'thirdparty_ns' => "ApacheBooster",
        'meta'          => {},
    };
    my $self = $class->SUPER::base( $ApacheBooster_new, $software_obj );

    return $self;
}

sub info {
    my ($self)   = @_;
    my $meta_obj = $self->meta();
    my $abstract = $meta_obj->abstract();
    return $abstract;
}

sub acl_desc {
    return [
        {
            'acl'              => 'software-ApacheBooster',       #this should be "software-$key"
            'default_value'    => 0,
            'default_ui_value' => 0,                        # NOTE: this is for ui; first time setting reseller privs
            'name'             => 'ApacheBooster',
            'acl_subcat'       => 'Third Party Services',
        },
    ];
}

1;
