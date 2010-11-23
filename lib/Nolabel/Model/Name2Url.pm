package Nolabel::Model::Name2Url;

use strict;
use base 'Catalyst::Model';

sub transform {
    my ($self, $name) = @_;
    $name =~ s/^\s+|\s+$//g;
    $name =~ s/\W+/-/g;
    $name =~ s/--+/-/g;
    $name =~ s/-$//g;
    return $name;
}

1;
