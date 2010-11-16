package CatalystX::Role::Sendfile;

use Moose::Role;
use namespace::autoclean;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

=head1 NAME

Catalyst::TraitFor::Controller::Sendfile - convenience method to send files with X-Sendfile, X-Accel-Redirect, ...

=head1 SYNOPSIS

    package MyApp::Controller::Foo;
    use Moose;
    use Path::Class qw/ file /;
    use namespace::clean;
    BEGIN {
        extends 'Catalyst::Controller';
        with 'Catalyst::TraitFor::Controller::Sendfile';
    }
    __PACKAGE__->config(sendfile_header => 'X-Sendfile');

    sub some_action : Local {
        my ($self, $c) = @_;
        $self->sendfile($c, Path::Class::File->new(qw/ path to file /));
    }

=head1 DESCRIPTION

If you want to deliver files using headers like 'X-Sendfile' or 'X-Accel-Redirect' you can apply this trait and use its convenience method sendfile.

=cut

=head2 sendfile_header

name of the Sendfile header. Probably 'X-Sendfile' or 'X-Accel-Redirect'. (Default: 'X-Sendfile')

=head2 sendfile

You call sendfile with $c and a Path::Class::File object. The file path can't be seen by the client. Your webserver should check if the 'X-Sendfile' header is set and if so deliver the file.

=cut

has sendfile_header => (
    is       => 'ro',
    isa      => 'Str',
    default  => 'X-Sendfile',
);

sub sendfile {
    my ($self, $c, $file, $content_type) = @_;

    # set the user supplied content_type
    if (defined $content_type) {
        $c->res->content_type($content_type);
    # get content_type from file extension
    } else {
        use MIMETypes;
        $c->res->content_type( MIMETypes::MIMEfromFile($file->basename) );
    }

    my $engine = $ENV{CATALYST_ENGINE} || '';

    # Catalyst development server
    if ( $engine =~ /^HTTP/ ) {
        if ( $file->stat && -f _ && -r _ ) {
            $c->res->body( $file->openr );
        }
    } 

    # Deployment with FastCGI
    elsif ( $engine eq 'FastCGI' ) {
        $c->res->header($self->sendfile_header, $file);
        $c->res->body("foo"); # MASSIVE HACK: bypass RenderView
    }

    # unknown engine
    else {
        die "Unknown engine: " . $engine;
    }

    $c->res->content_length( $file->stat->size );
    $c->res->status(200);
    $c->detach;
}

1;

=head1 AUTHORS

David Schmidt (davewood) C<< <davewood@gmx.at> >>

Florian Ragwitz C<< <rafl@debian.org> >>

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

