package Nolabel::Model::Confirmation;

use strict;
use base 'Catalyst::Model';

use Nolabel::Error::UserExists;
use Nolabel::Error::UserNotFound;
use Nolabel::Error::ConfirmationNotFound;

sub create {
    my ( $self, $c, $type, $data ) = @_;

    if ($type eq 'email') {
        # check if email exists and die if so
        check_email_available($c, $data->{email});
    } elsif ($type eq 'password') {
        # check if user exists
        get_user_by_email($c, $data->{email});
    } elsif ($type eq 'register') {
        # check if email exists and die if so
        check_email_available($c, $data->{email});
    }

    # make new entry in confirmation table
    my $confirmation = $c->model('DB::Confirmations')->create({
        type    => $type,
        data    => $data,
    });
    return $confirmation;
}

sub process {
    my ( $self, $c, $digest ) = @_;
    my $confirmation = get_confirmation($c, $digest);
    if ($confirmation->type eq 'register') {
        $self->new_user($c, $confirmation);
    }
    elsif ($confirmation->type eq 'email') {
        $self->new_email($c, $confirmation);
    }
    elsif ($confirmation->type eq 'password') {
        $self->new_password($c, $confirmation);
    }
    return $confirmation;
}

# get confirmation from digest
sub get_confirmation {
    my ( $c, $digest ) = @_;
    my $confirmation = $c->model('DB::Confirmations')->find({ digest => $digest });
    Nolabel::Error::ConfirmationNotFound->throw("Confirmation not found: $digest") 
        unless $confirmation;
    return $confirmation;
}

sub check_email_available {
    my ( $c, $email ) = @_;
    my $user = $c->model('DB::Users')->find({ email => $email });
    Nolabel::Error::UserExists->throw("Email exists: $email") 
        if $user;
}

sub get_user_by_id {
    my ( $c, $id ) = @_;
    my $user = $c->model('DB::Users')->find($id);
    Nolabel::Error::UserNotFound->throw("User not found: $id")
        unless $user;
}

sub get_user_by_email {
    my ( $c, $email ) = @_;
    my $user = $c->model('DB::Users')->find({ email => $email });
    Nolabel::Error::UserNotFound->throw("User not found: $email")
        unless $user;
}

# handle type 'password'
sub new_password {
    my ( $self, $c, $confirmation ) = @_;
    my $email = $confirmation->data->{email};
    my $user = get_user_by_email($c, $email);
    my $password = $user->new_password;
    $c->model('Email')->send_password($c, $user, $password);
}

# handle type 'email'
sub new_email {
    my ( $self, $c, $confirmation ) = @_;
    my $email = $confirmation->data->{email};
    my $user_id = $confirmation->data->{user_id};
    check_email_available($c, $email);
    my $user = get_user_by_id($c, $user_id);
    $user->update({ email => $email });
}

# handle type 'register'
sub new_user {
    my ( $self, $c, $confirmation ) = @_;
    my $email = $confirmation->data->{email};
    my $name = $confirmation->data->{name};
    check_email_available($c, $email);
    my $user = $c->model('DB::Users')->create({ name => $name, email => $email });
    my $password = $user->new_password;
    $c->model('Email')->send_password($c, $user, $password);
}

1;
