package Nolabel::Form::Artists;
use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler::Model::DBIC';

has '+item_class' => ( default => 'Artists' );

has 'user_id' => (
    is          => 'ro',
    isa         => 'Int',
    predicate   => 'has_user_id',
);

has_field 'name' => ( 
    type        => 'Text',
    required    => 1,
    size        => 40,
);

has_field 'description' => ( 
    type        => 'TextArea',
    required    => 1,
    size        => 40,
);

has_field 'submit' => ( id => 'btn_submit', type => 'Submit', value => 'Submit' );

around 'update_model' => sub {
    my $orig = shift;
    my $self = shift;
    my $item = $self->item;
    
    $self->schema->txn_do( sub {
        if($self->has_user_id) {
            $item->user_id($self->user_id);
        }
        $self->$orig(@_);
    } );
};

__PACKAGE__->meta->make_immutable;
