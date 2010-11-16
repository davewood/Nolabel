package Nolabel::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    # without this, fs_path isnt passed from config to the Schema fs_path
    traits       => 'SchemaProxy', 
);

use Moose;
# set media::fs_column_path as specified in MyApp->config
around 'COMPONENT' => sub {
    my ($orig, $class, $app, $args) = @_;
    my $self = $class->$orig($app, $args);
    $self->schema->source('Media')->column_info('file')->{fs_column_path} = $self->schema->fs_path();
    return $self;
};

1;
