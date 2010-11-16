package MIMETypes;
use MIME::Types;

sub _mime_types {
    my $mime = MIME::Types->new( only_complete => 1 );
    $mime->create_type_index;
    $mime;
}

sub MIMEfromFile {
    my $file = shift;

   # get content_type from file suffix
    my ($ext) = $file =~ /\.(.+?)$/;
    my ($mime, $type, $subtype);
    
    die 'Filename has no extension: ' . $file unless (defined $ext);
    
    $mime = _mime_types->mimeTypeOf($ext);

    die 'No MIME type found for file: ' . $file unless (defined $mime);

    return $mime;
}

1;
