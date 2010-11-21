package Nolabel::Form::Songs;
use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'Nolabel::Form::Media';

has '+item_class' => ( default => 'Songs' );

sub html_edit_file {
    my ( $self, $field ) = @_;
    my $song = $self->item;
    my $song_id = $song->id;
    my $artist_id = $song->artist->id;
    return qq{
        <div><label class="label">File: </label><a href="/artists/$artist_id/songs/$song_id/edit_file">edit</a></div>
    };
}
__PACKAGE__->meta->make_immutable;
