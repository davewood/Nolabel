package PasswordGenerator;
use Text::Password::Pronounceable;

sub password {
    return Text::Password::Pronounceable->generate(10);
}

1;

