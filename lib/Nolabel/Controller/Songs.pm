package Nolabel::Controller::Songs;
use Moose;
use namespace::autoclean;
use Nolabel::Form::Songs;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

with 'CatalystX::Role::Sendfile';
with 'CatalystX::TraitFor::Controller::SortableResource';
__PACKAGE__->config(
    parent_key          => 'user',
    parents_accessor    => 'songs',
    resultset_key       => 'songs_rs',
    resources_key       => 'songs',
    resource_key        => 'song',
    model               => 'DB::Songs',
    form_class          => 'Nolabel::Form::Songs',
    activate_fields_create => ['file'],
    activate_fields_edit => ['edit_file'],
    actions             => {
        base => {
            PathPart    => 'songs',
            Chained     => '/users/base_with_id',
        },
        (
            map {$_ => { Does => 'NeedsLogin' }} qw/
                                                    index
                                                    create
                                                    edit
                                                    delete
                                                    move_previous
                                                    move_next
                                                /,
        ),
    },
);

before [qw/index create edit edit_file delete move_previous move_next/] => sub {
    my ( $self, $c ) = @_;
    $c->detach('/denied') unless 
        ($c->user->id == $c->stash->{user}->id) || $c->check_user_roles('is_su');
};

# disable show action
before ['show'] => sub {
    my ( $self, $c ) = @_;
    $c->detach('/error404');
};

sub send : Chained('base_with_id') PathPart('') Args {
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

after [qw/move_previous move_next/] => sub {
    my ( $self, $c ) = @_;
    $c->res->redirect($c->uri_for($self->action_for('index'), [ $c->stash->{user}->id ]));
};

__PACKAGE__->meta->make_immutable;

1;
