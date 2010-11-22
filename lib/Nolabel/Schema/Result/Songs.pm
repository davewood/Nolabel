package Nolabel::Schema::Result::Songs;

use strict;
use warnings;

use base 'Nolabel::Schema::BaseResult::Media';

__PACKAGE__->table('songs');
__PACKAGE__->add_columns(
    'artist_id',
    {
        data_type   => 'integer',
        is_numeric  => 1,
        is_nullable => 0,
    },
);

__PACKAGE__->belongs_to(
    'artist',
    'Nolabel::Schema::Result::Artists',
    'artist_id'
);

__PACKAGE__->grouping_column('artist_id');

1;
