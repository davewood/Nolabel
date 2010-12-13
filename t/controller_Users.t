use strict;
use warnings;
use Test::More;

use_ok 'Test::WWW::Mechanize::Catalyst' => 'Nolabel';
BEGIN { use_ok 'Nolabel::Controller::Users' }

my $mech = Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok( '/', q{Request '/' should succeed} );
$mech->text_contains( 'Login', q{Content should contain string 'Login'} );

$mech->get_ok( '/register', q{Request '/register' should succeed} );
$mech->text_contains( 'Email:', q{Content should contain string 'Email:'} );

$mech->get_ok( '/login', q{Request '/login' should succeed} );
$mech->text_contains( 'Password:', q{Content should contain string 'Password:'} );
$mech->submit_form(
    fields => {
        username => 'davewood@gmx.at',
        password => 'oioioi',
    }
);

$mech->get_ok( '/login', q{Request '/login' should succeed} );
$mech->text_contains( 'Logout', q{Content should contain string 'Logout'} );

$mech->follow_link_ok( {text => 'Logout'}, 'follow logout link' );
$mech->get_ok( '/', q{Request '/' should succeed} );
$mech->text_contains( 'Login', q{Content should contain string 'Login' after logout} );

done_testing();
