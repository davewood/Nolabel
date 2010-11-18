package Nolabel::Schema::Result::Artists;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/
    InflateColumn::Object::Enum
    InflateColumn::DateTime 
    TimeStamp 
    Core
/);

__PACKAGE__->table('artists');
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
        is_nullable => 1,
        size        => 128,
    },
    'user_id',
    {
        data_type   => 'integer',
        is_numeric  => 1,
        is_nullable => 0,
    },
    "description",
    {
        data_type   => "text",
        is_nullable => 0,
    },
    'status',
    {
        data_type       => 'varchar',
        is_nullable     => 0,
        default_value   => 'active',
        is_enum         => 1,
        extra           => { list => [qw/active inactive/] },
    },
    'created',
    {
        data_type       => 'datetime',
        set_on_create   => 1,
        is_nullable     => 0,
    },
    'updated',
    {
        data_type       => 'datetime',
        set_on_update   => 1,
        set_on_create   => 1,
        is_nullable     => 0,
    },
);

__PACKAGE__->resultset_attributes({ order_by => 'name' });
__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
   'user',
   'Nolabel::Schema::Result::Users',
   'user_id',
);

1;
