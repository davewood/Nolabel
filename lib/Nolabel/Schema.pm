package Nolabel::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

use Moose;
has 'fs_path' => (
    is => 'rw',
    required => 1,
);

1;
