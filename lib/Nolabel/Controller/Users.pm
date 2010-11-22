package Nolabel::Controller::Users;
use Moose;
use namespace::autoclean;
use Nolabel::Form::Users;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

with 'CatalystX::TraitFor::Controller::Resource';
__PACKAGE__->config(
    resultset_key           => 'users_rs',
    resources_key           => 'users',
    resource_key            => 'user',
    model                   => 'DB::Users',
    form_class              => 'Nolabel::Form::Users',
    form_template           => 'users/form.tt',
    redirect_mode           => 'show',
    actions => {
        base => { 
            PathPart    => 'users', 
            Chained     => '/login/required', 
        },
        index => {
            Does            => 'ACL',
            AllowedRole     => ['is_su'],
            ACLDetachTo     => '/denied',
        },
    },
);

# disable actions
before [qw/create/] => sub {
    my ( $self, $c ) = @_;
    $c->detach('/error404');
};

before [qw/show edit delete send_password change_email edit_password/] => sub {
    my ( $self, $c ) = @_;
    my $user_id = $c->stash->{user}->id;
    $c->detach('/denied') unless 
        ($c->user->id == $user_id) || $c->check_user_roles('is_su');
};

# if users delete their account, logout and redirect to index
around 'delete' => sub {
    my ( $orig, $self, $c ) = @_;
    if ($c->user->id == $c->stash->{user}->id) {
        $self->$orig($c);
        $c->logout;
        $c->res->redirect('/');
    }
    else {
        $self->$orig($c);
    }
};

before 'edit' => sub {
    my ( $self, $c ) = @_;
    my $user = $c->stash->{user};

    # activate_form_fields already set (e.g. in "sub edit_password")
    return if ($c->stash->{activate_form_fields});

    # set active fields for edit form
    my @active;
    if ($user->artist) { push @active, 'edit_artist', 'edit_songs'; }
    if ($c->check_user_roles('is_su')) {
        push @active, qw/delete_account name email status roles edit_password/;
    }
    else {
        push @active, qw/delete_account change_email send_password/;
        if (!$user->artist) { push @active, 'create_artist'; }
    }
    $c->stash->{activate_form_fields} = \@active;
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
    $c->stash( 
        template    => 'users/form.tt', 
        form        => $form,
        msg         => 'Enter a new email address.',
    );
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
        }
        elsif ($error->isa('Nolabel::Error::EmailDeliveryFailed')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        }
        else {
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
    }
    catch {
        my $error = $_;
        if ($error->isa('Nolabel::Error::UserNotFound')) {
            $form->field('email')->add_error($error->message);
            $c->detach;
        }
        elsif ($error->isa('Nolabel::Error::EmailDeliveryFailed')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        }
        else {
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
            my $confirmation = $c->model('Confirmation')->create($c, 'register', { email => $email });
        
            # send the confirmation mail to the user
            $c->model('Email')->send_registration_confirmation($c, $email, $confirmation->digest);
        });
    }
    catch {
        my $error = $_;
        if ($error->isa('Nolabel::Error::UserExists')) {
            $form->field('email')->add_error($error->message);
            $c->detach;
        }
        elsif ($error->isa('Nolabel::Error::EmailDeliveryFailed')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        }
        else {
            die $error;
        }
    };  
            
    $c->flash(msg =>"A confirmation email with instructions has been sent to $email. Follow them to activate your account.");
    $c->res->redirect($c->uri_for($c->controller('Confirmations')->action_for('confirm_form')));
}

__PACKAGE__->meta->make_immutable;

1;
