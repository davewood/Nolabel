package Nolabel::Form::UsersBase;
use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';

has_field 'name' => ( 
    type        => 'Text',
    maxlength   => 100,
    inactive    => 1,
);

has_field 'email' => ( 
    type        => 'Email',
    maxlength   => 100,
    required    => 1,
    inactive    => 1,
);

has_field 'submit' => ( id => 'btn_submit', type => 'Submit', value => 'Submit' );

__PACKAGE__->meta->make_immutable;
