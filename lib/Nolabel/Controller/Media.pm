package Nolabel::Controller::Media;
use Moose;
use namespace::autoclean;
use Nolabel::Form::Media;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

with 'CatalystX::Role::Sendfile';
with 'CatalystX::TraitFor::Controller::SortableResource';
__PACKAGE__->config(
    parent_key          => 'artist',
    parents_accessor    => 'media',
    resultset_key       => 'media_rs',
    resources_key       => 'media',
    resource_key        => 'm',
    model               => 'DB::Media',
    form_class          => 'Nolabel::Form::Media',
    activate_fields_create => ['file'],
    activate_fields_edit => ['edit_file'],
    redirect_mode       => 'show_parent',
    actions             => {
        base => {
            PathPart    => 'media',
            Chained     => '/artists/base_with_id',
        },
    },
);

# disable show action
# disable index action
before ['show', 'index'] => sub {
    my ( $self, $c ) = @_;
    $c->detach('/error404');
};

sub send : Chained('base_with_id') PathPart('send') Args(0) Does('NeedsLogin') {
    my ( $self, $c ) = @_;
    my $media = $c->stash->{m};
    $self->sendfile($c, $media->file, $media->content_type);
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
    $c->detach('/media/edit');
}

__PACKAGE__->meta->make_immutable;

1;
