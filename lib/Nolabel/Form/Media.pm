package Nolabel::Form::Media;
use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'HTML::FormHandler::Model::DBIC';

has '+enctype' => ( default => 'multipart/form-data');

has_field 'name' => ( 
    type => 'Text',
    required => 1,
    minlength => 5,
);

has_field 'file' => ( 
    type => 'Upload',
    required => 1,
    max_size => 10000000,
    inactive    => 1,
);

has_field 'edit_file' => (
    type        => 'Display',
    inactive    => 1,
);

has_field 'submit' => ( id => 'btn_submit', type => 'Submit', value => 'Submit' );

before 'update_model' => sub {
    my $self = shift;
    my $item = $self->item;
    my $file = $self->params->{file};

    return unless($file); # file field in HFH is inactive

    use MIMETypes;
    my $mime = MIMETypes::MIMEfromFile($file->basename);
    my ($type, $subtype) = split('/', $mime);
    $item->content_type($mime);
    $item->media_type($type);

    # scale image (which is a Catalyst::Request::Upload Object)
    if($type eq 'image') {
        use ScaleImage;
        ScaleImage::scale($file->tempname, $subtype, 400, 400);
    }
};

# after validation we want { file => $filehandle }
# instead of { file => $catalyst_request_upload }
sub validate_file {
    my ( $self, $field ) = @_;
    $field->value($field->value->fh);
}

__PACKAGE__->meta->make_immutable;
