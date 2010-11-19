package Nolabel::Controller::Artists;
use Moose;
use namespace::autoclean;
use Nolabel::Form::Artists;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

with 'CatalystX::TraitFor::Controller::Resource';
__PACKAGE__->config(
#    parent_key          => 'user',
#    parents_accessor    => 'artist',
    resultset_key       => 'artists_rs',
    resources_key       => 'artists',
    resource_key        => 'artist',
    model               => 'DB::Artists',
    form_class          => 'Nolabel::Form::Artists',
    redirect_mode       => 'show',
    actions => {
        base    => { 
            PathPart    => 'artists', 
#            Chained     => '/users/base_with_id',
            Chained     => '/login/not_required',
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

before [qw/edit delete/] => sub {
    my ( $self, $c ) = @_;
    my $artist = $c->stash->{artist};
    my $user_id = $artist ? $artist->user->id : undef;
    $c->detach('/denied') unless 
        ($c->user->id == $user_id) || $c->check_user_roles('is_su');
};

before [qw/create/] => sub {
    my ( $self, $c ) = @_;
    if ($c->user->artist) {
        $c->stash( error_msg => 'You already have an artist page.');
        $c->detach('/denied');
    } 
    else {
        $c->stash(form_attrs => { user_id => $c->user->id });
    }
};

# override artists index
sub index :Path('/artists') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(artists => [ $c->model('DB::Artists')->all ]);
}

__PACKAGE__->meta->make_immutable;

1;
