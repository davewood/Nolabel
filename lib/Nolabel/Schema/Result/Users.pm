package Nolabel::Schema::Result::Users;

use strict;
use warnings;

use base 'DBIx::Class';
use PasswordGenerator;

__PACKAGE__->load_components(qw/
    DynamicDefault
    InflateColumn::Object::Enum
    EncodedColumn
    InflateColumn::DateTime 
    TimeStamp 
    Core
/);

__PACKAGE__->table('users');
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
    'email',
    {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 128,
    },
    'password',
    {
        data_type           => 'char',
        is_nullable         => 0,
        size                => 40 + 10,
        encode_column       => 1,
        encode_class        => 'Digest',
        encode_args         => {algorithm => 'SHA-1', format => 'hex', salt_length => 10},
        encode_check_method => 'check_password',
        dynamic_default_on_create => 'PasswordGenerator::password',
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
__PACKAGE__->add_unique_constraint( [qw/email/] );

__PACKAGE__->has_many(
    'user_roles',
    'Nolabel::Schema::Result::UserRoles',
    'user_id',
    { cascade_delete => 1 },
);

__PACKAGE__->many_to_many(
    'roles',
    'user_roles',
    'role'
);

sub new_password {
    my ($self) = @_;
    use PasswordGenerator;
    my $password = PasswordGenerator::password();
    $self->update({ password => $password });
    return $password;
}

1;
