package Nolabel::Controller::Songs;
use Moose;
use namespace::autoclean;
use Nolabel::Form::Songs;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

with 'CatalystX::Role::Sendfile';
with 'CatalystX::TraitFor::Controller::SortableResource';
__PACKAGE__->config(
    parent_key          => 'artist',
    parents_accessor    => 'songs',
    resultset_key       => 'songs_rs',
    resources_key       => 'songs',
    resource_key        => 'song',
    model               => 'DB::Songs',
    form_class          => 'Nolabel::Form::Songs',
    activate_fields_create => ['file'],
    activate_fields_edit => ['edit_file'],
    redirect_mode       => 'show_parent',
    actions             => {
        base => {
            PathPart    => 'songs',
            Chained     => '/artists/base_with_id',
        },
        index  => {
            Does        => 'NeedsLogin',
        },
        create  => {
            Does        => 'NeedsLogin',
        },
        edit    => {
            Does        => 'NeedsLogin',
        },
        delete  => {
            Does        => 'NeedsLogin',
        },
    },
);

before [qw/index create edit delete/] => sub {
    my ( $self, $c ) = @_;
    my $artist = $c->stash->{artist};
    my $user_id = $artist ? $artist->user->id : undef;
    $c->detach('/denied') unless 
        ($c->user->id == $user_id) || $c->check_user_roles('is_su');
};

# disable show action
before ['show'] => sub {
    my ( $self, $c ) = @_;
    $c->detach('/error404');
};

sub send : Chained('base_with_id') PathPart('send') Args(0) {
    my ( $self, $c ) = @_;
    my $song = $c->stash->{song};
    $self->sendfile($c, $song->file, $song->content_type);
}

# set the file param so HTML::FormHandler can work his magic
before 'form' => sub {
    my ( $self, $c, $resource, $activate_fields ) = @_;
    if ($c->req->method eq 'POST') {
        if ($c->req->upload('file')) {
            $c->req->params->{'file'} = $c->req->upload('file');
        }
    }
};

sub edit_file : Chained('base_with_id') PathPart('edit_file') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{activate_form_fields} = [qw/name file/];
    $c->detach('/songs/edit');
}

__PACKAGE__->meta->make_immutable;

1;
