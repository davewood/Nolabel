package Nolabel::Form::Artists;
use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';

has_field 'name' => ( 
    type        => 'Text',
    required    => 1,
    size        => 40,
);

has_field 'submit' => ( id => 'btn_submit', type => 'Submit', value => 'Submit' );

__PACKAGE__->meta->make_immutable;
