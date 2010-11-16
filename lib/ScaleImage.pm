package ScaleImage;
use namespace::autoclean;
use Imager;

sub scale {
    my ($file, $type, $x, $y) = @_;
    my $img = Imager->new;
    $img->read(file => $file, type => $type)
        or die 'Cannot load image: ' . $img->errstr;
    # default       ... 1024y768 => 533x400
    # type => 'min' ... 1024x768 => 400x300
    my $scaled_img = $img->scale(xpixels => $x, ypixels => $y, type => 'min')
        or die 'Cannot scale image: ' . $img->errstr;
    $scaled_img->write(file => $file, type => $type)
        or die 'Cannot save scaled image: ' . $scaled_img->errstr;
}

sub scaleY {
    my ($file, $type, $y) = @_;
    my $img = Imager->new;
    $img->read(file => $file, type => $type)
        or die 'Cannot load image: ' . $img->errstr;
    my $scaled_img = $img->scale(ypixels => $y)
        or die 'Cannot scale image: ' . $img->errstr;
    $scaled_img->write(file => $file, type => $type)
        or die 'Cannot save scaled image: ' . $scaled_img->errstr;
}

1;

