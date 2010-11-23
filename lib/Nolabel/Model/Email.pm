package Nolabel::Model::Email;

use strict;
use base 'Catalyst::Model';

use Nolabel::Error::EmailDeliveryFailed;

sub send_password {
    my ($self, $c, $user, $password) = @_;
    $c->model('DB')->schema->txn_do( sub {

        my $to = $user->email;
        my $subject  = 'Logindata for nolabel.at';
        my $template = 'logindata.tt';

        $c->stash(
            url         => $c->uri_for($c->controller('Login')->action_for('login')),
            username    => $to,
            password    => $password,
        );

        _send($c, $to, $template, $subject);
    });
}

sub send_lost_password_confirmation {
    my ($self, $c, $to, $digest) = @_;
    $c->model('DB')->schema->txn_do( sub {

        my $subject  = 'Lost Password Confirmation for nolabel.at';
        my $template = 'lost_password_confirmation.tt';

        my $url = $c->uri_for($c->controller('Confirmations')->action_for('confirm_form'));
        $c->stash(
            url_link    => "$url/$digest",
            url_form    => $url,
            username    => $to,
            digest      => $digest,
        );

        _send($c, $to, $template, $subject);
    });
}

sub send_registration_confirmation {
    my ($self, $c, $to, $digest) = @_;
    $c->model('DB')->schema->txn_do( sub {

        my $subject  = 'Registration Confirmation for nolabel.at';
        my $template = 'registration_confirmation.tt';

        my $url = $c->uri_for($c->controller('Confirmations')->action_for('confirm_form'));
        $c->stash(
            url_link    => "$url/$digest",
            url_form    => $url,
            username    => $to,
            digest      => $digest,
        );

        _send($c, $to, $template, $subject);
    });
}

sub send_email_confirmation {
    my ($self, $c, $to, $digest) = @_;
    $c->model('DB')->schema->txn_do( sub {

        my $subject  = 'Email Confirmation for nolabel.at';
        my $template = 'email_confirmation.tt';

        my $url = $c->uri_for($c->controller('Confirmations')->action_for('confirm_form'));
        $c->stash(
            url_link    => "$url/$digest",
            url_form    => $url,
            username    => $to,
            digest      => $digest,
        );

        _send($c, $to, $template, $subject);
    });
}

sub _send {
    my ($c, $to, $template, $subject) = @_;

    $c->stash->{email} = {
        from        => 'noreply@nolabel.at',
        to          => $to,
        subject     => $subject,
        template    => $template,
    };

    $c->forward( $c->view('Email') );

    if ( scalar( @{ $c->error } ) ) {
        Nolabel::Error::EmailDeliveryFailed->throw("Couldn't deliver email: $to");
    }
}

1;
