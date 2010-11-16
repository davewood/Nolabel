package Nolabel::Controller::Media;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Nolabel::Controller::Media in Media.');
}

__PACKAGE__->meta->make_immutable;

1;
