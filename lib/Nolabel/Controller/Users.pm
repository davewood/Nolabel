package Nolabel::Controller::Users;
use Moose;
use namespace::autoclean;
use Nolabel::Form::Users;

BEGIN { extends 
    'Catalyst::Controller::ActionRole',
}

# still render text/html with our View
__PACKAGE__->config(
    map => {
        'text/html' => [ 'View', 'HTML' ],
    }
);

with 'CatalystX::TraitFor::Controller::Resource';
__PACKAGE__->config(
    resultset_key           => 'users_rs',
    resources_key           => 'users',
    resource_key            => 'user',
    model                   => 'DB::Users',
    form_class              => 'Nolabel::Form::Users',
    form_template           => 'users/form.tt',
    redirect_mode           => 'show',
    #activate_fields_create  => ['name'],
    #activate_fields_edit    => ['edit_file'],
    actions         => {
        base => { 
            PathPart    => 'users', 
            Chained     => '/login/required', 
        },
    },
);

# disable actions
before [qw/create/] => sub {
    my ( $self, $c ) = @_;
    $c->detach('/error404');
};

# if users delete their account, logout and redirect to index
around 'delete' => sub {
    my ( $orig, $self, $c ) = @_;
    if ($c->user->id == $c->stash->{user}->id) {
        $self->$orig($c);
        $c->logout;
        $c->res->redirect('/');
    } else {
        $self->$orig($c);
    }
};

before 'edit' => sub {
    my ( $self, $c ) = @_;

    # activate_form_fields already set (e.g. in "sub edit_password")
    return if ($c->stash->{activate_form_fields});

    # set active fields for edit form
    if ($c->check_user_roles('admin')) {
        $c->stash->{activate_form_fields} = [qw/name email status roles edit_password/];
    }
    else {
        $c->stash->{activate_form_fields} = [qw/name status/];
    }
};

sub edit_password : Chained('base_with_id') PathPart('edit_password') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{activate_form_fields} = ['password', 'password_confirm'];
    $c->detach('/users/edit');
}

sub change_email : Chained('base_with_id') PathPart('change_email') Args(0) {
    my ( $self, $c ) = @_;

    use Nolabel::Form::UsersBase;
    my $form = Nolabel::Form::UsersBase->new;
    $form->process( 
        active  => [qw/email/],
        params  => $c->req->params,
    );
    $c->stash( template => 'users/form.tt', form => $form );
    return unless $form->validated;

    my $email = $form->field('email')->value;

    use Try::Tiny;
    try {
        # make new entry in confirmation table
        $c->model('DB')->schema->txn_do( sub {
            # creates the confirmation and puts the digest into c.stash.digest
            my $confirmation = $c->model('Confirmation')->create($c, 'email', { email => $email, user_id => $c->stash->{user}->id });
       
            # send the confirmation mail to the user
            $c->model('Email')->send_email_confirmation($c, $email, $confirmation->digest);
        });
    } catch {
        my $error = $_;
        if ($error->isa('Nolabel::Error::UserExists')) {
            $form->field('email')->add_error($error->message);
            $c->detach;
        } elsif ($error->isa('Nolabel::Error::EmailDeliveryFailed')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        } else {
            die $error;
        }
    };

    $c->flash(msg =>"A confirmation email with instructions has been sent to $email. Follow them to change your email.");
    $c->res->redirect($c->uri_for($c->controller('Confirmations')->action_for('confirm_form')));
}

# send user mail with link, username and password
sub send_password : Chained('base_with_id') PathPart('send_password') Args(0) {
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    my $password = $user->new_password;
    $c->model('Email')->send_password($c, $user, $password);

    my $msg = 'An email with logindata has been sent to ' . $user->email;
    $c->log->info($msg);
    $c->flash(msg => $msg);
    $c->res->redirect($c->uri_for($self->action_for('show'), [$user->id]));
}

sub lost_password : Path('/lost_password') Args(0) {
    my ( $self, $c ) = @_;

    use Nolabel::Form::UsersBase;
    my $form = Nolabel::Form::UsersBase->new;

    $form->process(
        active  => [qw/email/],
        params  => $c->req->params,
    );
    $c->stash( template => 'users/form.tt', form => $form );

    return unless $form->validated;

    my $email = $form->field('email')->value;

    use Try::Tiny;
    try {
        $c->model('DB')->schema->txn_do( sub {
            # creates the confirmation and puts the digest into c.stash.digest
            my $confirmation = $c->model('Confirmation')->create($c, 'password', { email => $email });

            # send the confirmation mail to the user
            $c->model('Email')->send_lost_password_confirmation($c, $email, $confirmation->digest);
        });
    } catch {
        my $error = $_;
        if ($error->isa('Nolabel::Error::UserNotFound')) {
            $form->field('email')->add_error($error->message);
            $c->detach;
        } elsif ($error->isa('Nolabel::Error::EmailDeliveryFailed')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        } else {
            die $error;
        }
    };

    $c->flash(msg =>"A confirmation email with instructions has been sent to $email.");
    $c->res->redirect($c->uri_for($c->controller('Confirmations')->action_for('confirm_form')));
}

sub register : Path('/register') Args(0) {
    my ( $self, $c ) = @_;
    
    if ($c->user_exists) {
        $c->stash( error_msg => 'You are already logged in.');
        $c->detach('/denied');
    }
    
    use Nolabel::Form::UsersBase;
    my $form = Nolabel::Form::UsersBase->new;

    $form->process(  
        active  => [qw/name email/],
        params  => $c->req->params,
    ); 
    $c->stash( template => 'users/form.tt', form => $form );
   
    return unless $form->validated;

    my $email = $form->field('email')->value;
    my $name = $form->field('name')->value;
    
    use Try::Tiny; 
    try {   
        $c->model('DB')->schema->txn_do( sub {
            # creates the confirmation and puts the digest into c.stash.digest
            my $confirmation = $c->model('Confirmation')->create($c, 'register', { email => $email, name => $name });
        
            # send the confirmation mail to the user
            $c->model('Email')->send_registration_confirmation($c, $email, $confirmation->digest);
        });
    } catch {
        my $error = $_;
        if ($error->isa('Nolabel::Error::UserExists')) {
            $form->field('email')->add_error($error->message);
            $c->detach;
        } elsif ($error->isa('Nolabel::Error::EmailDeliveryFailed')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        } else {
            die $error;
        }
    };  
            
    $c->flash(msg =>"A confirmation email with instructions has been sent to $email. Follow them to activate your account.");
    $c->res->redirect($c->uri_for($c->controller('Confirmations')->action_for('confirm_form')));
}


__PACKAGE__->meta->make_immutable;

1;