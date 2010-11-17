package Nolabel;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

use Catalyst qw/
    ConfigLoader
    +CatalystX::SimpleLogin
    Static::Simple
    Authentication
    Authorization::Roles
    Session
    Session::State::Cookie
    Session::Store::FastMmap
    Unicode::Encoding
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

__PACKAGE__->config(
    name => 'Nolabel',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    default_view    => 'HTML',
    default_model   => 'DB',
    session => { flash_to_stash => 1 },
    'Plugin::Authentication' => {
        default => {
            store => {
                class           => 'DBIx::Class',
                user_model      => 'DB::Users',
                role_relation   => 'roles',
                role_field      => 'name',
            },
            credential => {
                class           => 'Password',
                password_field  => 'password',
                password_type   => 'self_check',
            },
        },
    },
    'Controller::Login' => {
        traits => ['-RenderAsTTTemplate'], # remove trait, requires custom login.tt
        login_form_args => {
            # we authenticate using 'email', not 'username'
            field_list => [
                '+username' => { label => 'Email' },
                '+remember' => { inactive => 1, required => 0 },
            ],
            authenticate_username_field_name => 'email',
        },
    },
    'View::HTML' => {
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root', 'templates' )
        ],
        TEMPLATE_EXTENSION  => '.tt',
        WRAPPER             => 'wrapper.tt',
        ENCODING            => 'UTF-8',
        render_die          => 1,
    },
    'View::Plaintext' => {
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root', 'templates' )
        ],
        TEMPLATE_EXTENSION  => '.tt',
        ENCODING            => 'UTF-8',
        render_die          => 1,
    },
    'View::Email' => {
        stash_key       => 'email',
        template_prefix => 'emails',
        default => {
            content_type    => 'text/plain',
            charset         => 'utf-8',
            view            => 'Plaintext',
        },
        sender => {
            mailer => 'SMTP',
            mailer_args => {
                ssl      => 1,
                port     => 465,
                host     => 'smtp.gmail.com',
                sasl_username => '###',
                sasl_password => '###',
            }
        }
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
