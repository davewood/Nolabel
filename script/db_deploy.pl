#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Nolabel::Schema;

my $schema = Nolabel::Schema->connect(
            ("dbi:Pg:database=nolabel", 'nolabel', 'gibson')
    ) or die "Unable to connect\n";

$schema->deploy({ add_drop_table => 1} );

#$schema->resultset('Roles')->create({id => 1, name => 'admin'});
#$schema->resultset('Roles')->create({id => 2, name => 'therapist'});
#$schema->resultset('Roles')->create({id => 3, name => 'patient'});
#my $user = $schema->resultset('Users')->create({name => 'David Schmidt', email => 'davewood@gmx.at', password => 'oioioi'});
#$user->add_to_roles({ name => 'admin' });

