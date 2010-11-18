package Nolabel::Controller::Confirmations;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub confirm_form : Path('/confirm') Args(0) {
    my ( $self, $c ) = @_;
    use Nolabel::Form::Confirmations;
    my $form = Nolabel::Form::Confirmations->new();

    $form->process( params  => $c->req->params );

    my $rendered_form = $form->render;
    $c->stash( template => \$rendered_form );

    return unless $form->validated;
    my $digest = $c->req->params->{digest};
    $self->_confirm($c, $digest);
}

sub confirm_link : Path('/confirm') Args(1) {
    my ( $self, $c, $digest ) = @_;
    $self->_confirm($c, $digest);
}

sub _confirm {
    my ( $self, $c, $digest ) = @_;

    use Try::Tiny;
    try {
        $c->model('DB')->schema->txn_do( sub {
            my $confirmation = $c->model('Confirmation')->process($c, $digest);
    
            if ($confirmation->type eq 'register') {
                my $user = $c->find_user({ email => $confirmation->data->{email} }); # set_authenticated needs a user from the store
                $c->set_authenticated($user); # logs the user in
                $c->flash(msg => 'Registration successful!');
                $c->res->redirect($c->uri_for($c->controller('Artists')->action_for('create'), [ $user->id ]));
            } elsif ($confirmation->type eq 'email') {
                $c->flash(msg => 'Email confirmed!');
                $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            } elsif ($confirmation->type eq 'password') {
                my $user = $c->find_user({ email => $confirmation->data->{email} }); # set_authenticated needs a user from the store
                $c->set_authenticated($user); # logs the user in
                $c->flash(msg => 'Password confirmed!');
                $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            }
            $confirmation->delete;
        });
    } catch {
        my $error = $_;
        if ($error->isa('Nolabel::Error::ConfirmationNotFound')) {
            $c->stash(error_msg => $error->message);
            $c->detach('/error404');
        } elsif ($error->isa('Nolabel::Error::UserExists')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        } elsif ($error->isa('Nolabel::Error::UserNotFound')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        } elsif ($error->isa('Nolabel::Error::EmailDeliveryFailed')) {
            $c->flash(error_msg => $error->message);
            $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
            $c->detach;
        } else {
            die $error;
        }
    };
}

__PACKAGE__->meta->make_immutable;

1;
