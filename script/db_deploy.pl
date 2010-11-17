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





$schema->resultset('Roles')->create({id => 1, name => 'is_su'});
$schema->resultset('Roles')->create({id => 2, name => 'can_edit_password'});
$schema->resultset('Roles')->create({id => 3, name => 'can_change_email'});

my $user;

$user = $schema->resultset('Users')->create({name => 'David Schmidt', email => 'davewood@gmx.at', password => 'oioioi'});
$user->add_to_roles({ name => 'is_su' });

$user = $schema->resultset('Users')->create({name => 'Jonny Awesome', email => 'zivildiener+1@gmail.com', password => 'oioioi'});
$user->add_to_roles({ name => 'can_edit_password' });
$user->add_to_roles({ name => 'can_change_email' });

