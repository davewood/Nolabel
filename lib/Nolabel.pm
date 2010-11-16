package Nolabel;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

# Configure the application.
#
# Note that settings in nolabel.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Nolabel',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    default_view    => 'HTML',
    default_model   => 'DB',
    session => { flash_to_stash => 1 },
#    'Plugin::Authentication' => {
#        default => {
#            store => {
#                class           => 'DBIx::Class',
#                user_model      => 'DB::Users',
#                role_relation   => 'roles',
#                role_field      => 'name',
#            },
#            credential => {
#                class           => 'Password',
#                password_field  => 'password',
#                password_type   => 'self_check',
#            },
#        },
#    },
#    'Controller::Login' => {
#        login_form_args => {
#            # we authenticate using 'email', not 'username'
#            field_list => {
#                '+username' => { label => 'Email' },
#            },
#            authenticate_username_field_name => 'email',
#            # only users with status 'active' may log in
#            #authenticate_args => { status => 'active' },
#        },
#    },
    'View::HTML' => {
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root', 'templates' )
        ],
        TEMPLATE_EXTENSION  => '.tt',
        WRAPPER             => 'wrapper.tt',
        ENCODING            => 'UTF-8',
    },
    'Model::DB' => {
        fs_path      => __PACKAGE__->path_to( qw/ root static media / ),
        schema_class => 'Nolabel::Schema',
        connect_info => {
            dsn         => 'dbi:Pg:database=nolabel',
            user        => 'nolabel',
            password    => 'gibson',
            AutoCommit  => 1,
            pg_enable_utf8 => 1,
        },
    },
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

Nolabel - Catalyst based application

=head1 SYNOPSIS

    script/nolabel_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Nolabel::Controller::Root>, L<Catalyst>

=head1 AUTHOR

David Schmidt,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
