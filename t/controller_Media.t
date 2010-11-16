use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Nolabel' }
BEGIN { use_ok 'Nolabel::Controller::Media' }

ok( request('/media')->is_success, 'Request should succeed' );
done_testing();
