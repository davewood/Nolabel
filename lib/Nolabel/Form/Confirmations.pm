package Nolabel::Form::Confirmations;
use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';

has_field 'digest' => ( 
    type        => 'Text',
    required    => 1,
    size        => 40,
);

has_field 'submit' => ( id => 'btn_submit', type => 'Submit', value => 'Confirm' );

__PACKAGE__->meta->make_immutable;
