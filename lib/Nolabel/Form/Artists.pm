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
    apply       => [{ transform => sub {
        my $value = shift;
        use HTML::Scrubber;
        my $scrubber = HTML::Scrubber->new( allow => [ qw/p br strong ul li/ ] );
        $scrubber->scrub($value);
    }}]
);

has_field 'status' => ( 
    type        => 'Select',
    widget      => 'radio_group',
    inactive    => 1,
    required    => 1,
    options     => [ map { { value => $_, label => $_} } qw/active inactive/ ],
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
