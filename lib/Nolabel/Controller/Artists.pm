package Nolabel::Controller::Artists;
use Moose;
use namespace::autoclean;
use Nolabel::Form::Artists;

BEGIN { extends 'Catalyst::Controller' }

with 'CatalystX::TraitFor::Controller::Resource';
__PACKAGE__->config(
    resultset_key           => 'artists_rs',
    resources_key           => 'artists',
    resource_key            => 'artist',
    model                   => 'DB::Artists',
    form_class              => 'Nolabel::Form::Artists',
    form_template           => 'artists/form.tt',
    redirect_mode           => 'show',
    #activate_fields_create  => ['name'],
    #activate_fields_edit    => ['edit_file'],
    actions         => {
        base => { 
            PathPart    => 'artists', 
            Chained     => '/login/required', 
        },
    },
);

# disable actions
before [qw/create/] => sub {
    my ( $self, $c ) = @_;
    $c->detach('/error404');
};

#sub register : Path('/register') Args(0) {
#    my ( $self, $c ) = @_;
#    
#    if ($c->user_exists) {
#        $c->stash( error_msg => 'You are already logged in.');
#        $c->detach('/denied');
#    }
#    
#    use Nolabel::Form::UsersBase;
#    my $form = Nolabel::Form::UsersBase->new;
#
#    $form->process(  
#        active  => [qw/name email/],
#        params  => $c->req->params,
#    ); 
#    $c->stash( template => 'users/form.tt', form => $form );
#   
#    return unless $form->validated;
#
#    my $email = $form->field('email')->value;
#    my $name = $form->field('name')->value;
#    
#    use Try::Tiny; 
#    try {   
#        $c->model('DB')->schema->txn_do( sub {
#            # creates the confirmation and puts the digest into c.stash.digest
#            my $confirmation = $c->model('Confirmation')->create($c, 'register', { email => $email, name => $name });
#        
#            # send the confirmation mail to the user
#            $c->model('Email')->send_registration_confirmation($c, $email, $confirmation->digest);
#        });
#    } catch {
#        my $error = $_;
#        if ($error->isa('Nolabel::Error::UserExists')) {
#            $form->field('email')->add_error($error->message);
#            $c->detach;
#        } elsif ($error->isa('Nolabel::Error::EmailDeliveryFailed')) {
#            $c->flash(error_msg => $error->message);
#            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
#            $c->detach;
#        } else {
#            die $error;
#        }
#    };  
#            
#    $c->flash(msg =>"A confirmation email with instructions has been sent to $email. Follow them to activate your account.");
#    $c->res->redirect($c->uri_for($c->controller('Confirmations')->action_for('confirm_form')));
#}


__PACKAGE__->meta->make_immutable;

1;
