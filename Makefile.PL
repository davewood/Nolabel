#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Nolabel';
all_from 'lib/Nolabel.pm';

requires 'Catalyst::Runtime' => '5.80025';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';

requires 'Moose';
requires 'namespace::autoclean';

requires 'Config::General';

requires 'HTML::FormHandler';
requires 'HTML::Scrubber';

requires 'Text::Password::Pronounceable';

requires 'Class::Method::Modifiers' # to change one dbic field if another one changes

requires 'Digest::SHA';
requires 'DBIx::Class::Ordered';
requires 'DBIx::Class::EncodedColumn';
requires 'DBIx::Class::DynamicDefault';
requires 'DBIx::Class::InflateColumn::Currency'; # from/to Data::Currency
requires 'DBIx::Class::InflateColumn::DateTime';
requires 'DBIx::Class::InflateColumn::DateTime::Duration';
requires 'DBIx::Class::InflateColumn::Object::Enum ';
requires 'DBIx::Class::ResultSet::HashRef';

# for serializing data and storing in DB
requires 'JSON::Any',
requires 'JSON::XS',
requries 'DBIx::Class::InflateColumn::Serializer::JSON',

requires 'Catalyst::Model::PayPal::IPN';

test_requires 'Test::More' => '0.88';

# mail sending

# for C::V::Email
requires 'Net::SMTP::SSL'; # building needs libssl+libssl-dev
requires 'Catalyst::View::Email::Template'

requires 'Perl6::Junction';

requires 'Imager';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
