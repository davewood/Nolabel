package Nolabel::Controller::Artists;
use Moose;
use namespace::autoclean;
use Nolabel::Form::Artists;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

with 'CatalystX::TraitFor::Controller::Resource';
__PACKAGE__->config(
    resultset_key       => 'artists_rs',
    resources_key       => 'artists',
    resource_key        => 'artist',
    model               => 'DB::Artists',
    form_class          => 'Nolabel::Form::Artists',
    activate_fields_edit=> [qw/status/],
    redirect_mode       => 'show',
    actions => {
        base    => { 
            PathPart    => 'artists', 
            Chained     => '/login/not_required',
        },
        show    => {
            # so we can attach the artists name to the url
            Args        => undef,
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

before 'create' => sub {
    my ( $self, $c ) = @_;
    if ($c->user->artist) {
        $c->stash( error_msg => 'You already have an artist page.');
        $c->detach('/denied');
    } 
    elsif ($c->check_user_roles('is_su')) {
        $c->stash( error_msg => 'Superusers can not have artist pages');
        $c->detach('/denied');
    }
    else {
        $c->stash(form_attrs => { user_id => $c->user->id });
    }
};

around '_redirect' => sub {
    my ( $orig, $self, $c) = @_;
    $c->res->redirect($c->uri_for($c->controller('Users')->action_for('show'), [$c->stash->{artist}->user->id]));
};

# override artists index
sub index : Path('/artists') Args(0) {
    my ( $self, $c ) = @_;

    use HTML::FormHandler;
    my $form = HTML::FormHandler->new(
        http_method => 'GET',
        field_list => [
            search => { 
                type        => 'Text', 
                required    => 1, 
                size        => 40, 
                minlength   => 3, 
                label       => '',
            },
            submit => { type => 'Submit', value => 'Search' },
        ],
    );

    $form->process( params  => $c->req->params );

    $c->stash( form => $form );

    if ($form->validated) {
        my $search = $form->field('search')->value;
        my @artists = $c->model('DB::Artists')->search({ 
                status => 'active', 
                name => { like => '%' . $search . '%'} 
            });
        my $num_artists = scalar @artists;
        if($num_artists) {
            $c->stash( artists => \@artists );
        }
        $c->stash( msg => "$num_artists artist(s) found for '$search'" );
    }
    else {
        $c->stash(artists => [ $c->model('DB::Artists')->search({ status => 'active' }) ]);
    }
}


__PACKAGE__->meta->make_immutable;

1;
