package Nolabel::Schema::Result::Confirmations;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/
    InflateColumn::Serializer 
    DynamicDefault
    EncodedColumn
    InflateColumn::DateTime 
    TimeStamp 
    Core
/);

__PACKAGE__->table('confirmations');
__PACKAGE__->add_columns(
    'id',
    {
        data_type           => 'integer',
        is_nullable         => 0,
        is_auto_increment   => 1,
        is_numeric          => 1,
    },
    'digest',
    {
        data_type           => 'char',
        is_nullable         => 0,
        size                => 40,
        encode_column       => 1,
        encode_class        => 'Digest',
        encode_args         => {algorithm => 'SHA-1', format => 'hex'},
        dynamic_default_on_create => 'digest_data',
    },
    'data',
    {
        data_type           => 'text',
        serializer_class    => 'JSON',
    },
    'type',
    {
        data_type       => 'varchar',
        is_nullable     => 0,
        is_enum         => 1,
        extra           => { list => [qw/password email register/] },
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

__PACKAGE__->resultset_attributes({ order_by => 'created' });
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [qw/digest/] );

sub digest_data {
    my @salt_pool = ('A' .. 'Z', 'a' .. 'z', 0 .. 9, '+','/','=');
    my $slen = 10;
    my $salt ||= join('', map { $salt_pool[int(rand(65))] } 1 .. $slen);
    my $digest_data = time . $salt;
    return $digest_data;
}

1;
