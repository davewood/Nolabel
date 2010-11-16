package CatalystX::TraitFor::Controller::SortableResource;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use namespace::autoclean;

our $VERSION = '0.01';

with 'CatalystX::TraitFor::Controller::Resource';

=head1 NAME

CatalystX::TraitFor::Controller::SortableResource - a Sortable CRUD Role for your Controller

=head1 SYNOPSIS

see L<CatalystX::TraitFor::Controller::Resource>

=head1 DESCRIPTION

adds these paths to your Controller 

    /resource/*/move_previous
    /resource/*/move_next

=head2 move_previous
    
    will switch the resource with the previous one

=head2 move_next
    
    will switch the resource with the next one

=cut

sub move_next :Chained('base_with_id') :PathPart('move_next') :Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{$self->resource_key};
    $resource->move_next;
    $self->redirect($c);
}

sub move_previous :Chained('base_with_id') :PathPart('move_previous') :Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{$self->resource_key};
    $resource->move_previous;
    $self->redirect($c);
}

sub redirect {
    my ( $self, $c ) = @_;
    if($self->has_parent) {
        $c->response->redirect($c->uri_for($self->action_for('index'), [ $c->stash->{$self->parent_key}->id ]));
    } else {
        $c->response->redirect($c->uri_for($self->action_for('index')));
    }
}

=head1 AUTHOR

=over

=item David Schmidt (davewood) C<< <davewood@gmx.at> >>

=back

=head1 LICENSE

Copyright 2010 David Schmidt. Some rights reserved.

This software is free software and is licensed under the same terms as perl itself.

=cut

1;
