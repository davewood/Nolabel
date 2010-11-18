package Nolabel::Form::Users;
use HTML::FormHandler::Moose;
use namespace::autoclean;

extends (qw/
    HTML::FormHandler::Model::DBIC
    Nolabel::Form::UsersBase 
/);

has '+item_class' => ( default => 'Users' );
has '+enctype' => ( default => 'multipart/form-data');

has 'role' => (
    is          => 'ro',
    isa         => 'Str',
    predicate   => 'has_role',
);

has 'user_id' => (
    is          => 'ro',
    isa         => 'Int',
    predicate   => 'has_user_id',
);

# extend email from UsersBase.pm
has_field '+email' => ( 
    unique      => 1,
);

has_field 'edit_password' => (
    type        => 'Display',
    inactive    => 1,
);
sub html_edit_password {
    my ( $self, $field ) = @_;
    my $user_id = $self->item->id;
    return qq{<div><label class="label">Password: </label><a class="button" href="/users/$user_id/edit_password">edit password</a></div>};
}

has_field 'change_email' => (
    type        => 'Display',
    inactive    => 1,
);
sub html_change_email {
    my ( $self, $field ) = @_;
    my $user_id = $self->item->id;
    return qq{<div><label class="label">Email: </label><a class="button" href="/users/$user_id/change_email">change email</a></div>};
}

has_field 'status' => ( 
    type        => 'Select',
    widget      => 'radio_group',
    required    => 1,
    inactive    => 1,
    options     => [ map { { value => $_, label => $_} } qw/active inactive/ ],
);

has_field 'password'         => ( 
    type        => 'Password',
    minlength   => 8,
    required    => 1,
    inactive    => 1,
);

has_field 'send_password' => (
    type        => 'Display',
    inactive    => 1,
);
sub html_send_password {
    my ( $self, $field ) = @_;
    my $user_id = $self->item->id;
    return qq{
        <div>
            <label class="label">Password: </label>
            <form class="button" action="/users/$user_id/send_password">
                <input type="submit" value="send new password"
                    onclick="javascript:return confirm('Do you really want to send a new password?')">
            </form>
        </div>
    };
}

has_field 'password_confirm' => ( 
    type        => 'PasswordConf',
    required    => 1,
    inactive    => 1,
    noupdate    => 1,
);

has_field 'roles' => ( 
    type        => 'Select',
    widget      => 'checkbox_group',
    multiple    => 1,
    inactive    => 1,
);

has_field 'delete_account' => (
    type        => 'Display',
    inactive    => 1,
);
sub html_delete_account {
    my ( $self, $field ) = @_;
    my $user_id = $self->item->id;
    return qq{
        <div>
            <label class="label">Account: </label>
            <form class="button" action="/users/$user_id/delete">
                <input type="submit" value="delete" 
                    onclick="javascript:return confirm('Do you really want to delete this user?')">
            </form>
        </div>
    };
}

__PACKAGE__->meta->make_immutable;
