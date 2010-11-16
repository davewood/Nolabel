package Nolabel::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub index : Path Args(0) {}

sub default : Path {
    my ( $self, $c ) = @_;
    $c->detach('/error404');
}

sub denied : Private {
    my ( $self, $c ) = @_;
    unless ($c->stash->{error_msg}) {
        $c->stash(error_msg => 'Access denied!');
    }
    $c->res->status(403);
    $c->stash(template => 'index.tt');
}

sub error404 : Private {
    my ( $self, $c ) = @_;
    unless ($c->stash->{error_msg}) {
        $c->stash(error_msg => 'Page not found. 404');
    }
    $c->res->status(404);
    $c->stash(template => 'error.tt');
}

sub error400 : Private {
    my ( $self, $c ) = @_;
    unless ($c->stash->{error_msg}) {
        $c->stash(error_msg => 'Bad Request. 400');
    }
    $c->res->status(400);
    $c->stash(template => 'error.tt');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : Private {
    my ($self, $c) = @_;

    # set 'render_die => 1' for Nolabel::View::TT in Nolabel.pm 
    # for correct error handling behaviour
    $c->forward('render');

    # display catalyst error page in case of an error
    return if $c->debug;

    # in production log error and display nice error page
    if (@{$c->error}) {
        for my $error (@{$c->error}) {
            $c->log->error($error);
        }

        use Try::Tiny;
        if (my $user = try { $c->user }) { $c->log->error('User: ' . $user->id) }
        
        $c->log->error('Request: ' . $c->request->uri);
        $c->stash(template => 'error.tt');
        $c->clear_errors;
        $c->forward('render'); # trigger rendering
    }
}

sub render : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;
