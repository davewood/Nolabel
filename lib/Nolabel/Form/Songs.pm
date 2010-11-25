package Nolabel::Form::Songs;
use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'Nolabel::Form::Media';

has '+item_class' => ( default => 'Songs' );

sub html_edit_file {
    my ( $self, $field ) = @_;
    my $song = $self->item;
    my $song_id = $song->id;
    my $user_id = $song->user->id;
    return qq{
        <div><label class="label">File: </label><a href="/users/$user_id/songs/$song_id/edit_file">edit</a></div>
    };
}

around 'validate_file' => sub {
    my ( $orig, $self, $field ) = @_;
    my $filename = $field->value->basename;
    if ($filename =~ m/\.mp3$/) {
        $self->$orig($field);
    }
    else {
        $field->add_error("File must be a mp3 file: $filename");
    }
};

__PACKAGE__->meta->make_immutable;
