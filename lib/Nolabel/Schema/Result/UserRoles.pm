package Nolabel::Schema::Result::UserRoles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/
    Core
/);

__PACKAGE__->table('user_roles');
__PACKAGE__->add_columns(
    'id',
    {
        data_type           => 'integer',
        is_nullable         => 0,
        is_auto_increment   => 1,
        is_numeric          => 1,
    },
    'user_id',
    {
        data_type   => 'integer',
        is_nullable => 0,
        is_numeric  => 1,
    },
    'role_id',
    {
        data_type   => 'integer',
        is_numeric  => 1,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [qw/user_id role_id/] );

__PACKAGE__->belongs_to(
    'user',
    'Nolabel::Schema::Result::Users',
    'user_id'
);

__PACKAGE__->belongs_to(
    'role',
    'Nolabel::Schema::Result::Roles',
    'role_id'
);

1;
