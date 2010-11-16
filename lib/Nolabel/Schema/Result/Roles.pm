package Nolabel::Schema::Result::Roles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/
    Core
/);

__PACKAGE__->table('roles');
__PACKAGE__->add_columns(
    'id',
    {
        data_type           => 'integer',
        is_nullable         => 0,
        is_auto_increment   => 1,
        is_numeric          => 1,
    },
    'name',
    {
        data_type   => 'varchar',
        size        => 32,
        is_nullable => 0,
    },
);

__PACKAGE__->resultset_attributes({ order_by => 'name' });
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [qw/name/] );

1;
