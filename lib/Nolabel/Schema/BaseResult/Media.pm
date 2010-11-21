package Nolabel::Schema::BaseResult::Media;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/
    Ordered
    InflateColumn::Object::Enum
    InflateColumn::DateTime
    InflateColumn::FS
    TimeStamp
    Core
/);

__PACKAGE__->table('media');
__PACKAGE__->add_columns(
    'id',
    {
        data_type           => 'integer',
        is_auto_increment   => 1,
        is_numeric          => 1,
        is_nullable         => 0,
    },
    'name',
    {
        data_type   => 'varchar',
        size        => 64,
        is_nullable => 0,
    },
    'position',
    {
        data_type   => 'integer',
        is_nullable => 0,
    },
    'file',
    {
        data_type       => 'varchar',
        size            => 128,
        is_fs_column    => 1,
        #fs_column_path => '/tmp', # we set this value in config in lib/MyApp.pm
    },
    'content_type',
    {
        data_type   => 'varchar',
        size        => 32,
        is_nullable => 0,
    },
    'media_type',
    {
        data_type   => 'varchar',
        size        => 32,
        is_nullable => 0,
        is_enum     => 1,
        extra       => { list => [qw/image audio video/] },
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

__PACKAGE__->resultset_attributes({ order_by => 'position' });
__PACKAGE__->position_column('position');
#__PACKAGE__->grouping_column('user_id');

__PACKAGE__->set_primary_key('id');

1;
