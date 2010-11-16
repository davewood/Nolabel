package CatalystX::TraitFor::Controller::Resource;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

our $VERSION = '0.01';

=head1 NAME

CatalystX::TraitFor::Controller::Resource - CRUD Role for your Controller

=head1 SYNOPSIS

    # a Resource Controller
    package Physio::Controller::Exercises;
    with 'CatalystX::TraitFor::Controller::Resource';
    __PACKAGE__->config(
        resultset_key   => 'exercises_rs',
        resources_key   => 'exercises',
        resource_key    => 'exercise',
        model           => 'DB::Exercises',
        form_class      => 'Physio::Form::Exercises',
        form_template   => 'exercises/form.tt',
        actions         => {
            base => {
                PathPart    => 'exercises',
                Chained     => '',
                CaptureArgs => 0,
            },
        },
    );
    
    # a nested Resource Controller
    package Physio::Controller::Media;
    with 'CatalystX::TraitFor::Controller::Resource';
    __PACKAGE__->config(
        parent_key         => 'exercise',
        parents_accessor   => 'media',
        resultset_key      => 'media_rs',
        resources_key      => 'media',
        resource_key       => 'm',
        model              => 'DB::Media',
        form_class         => 'Physio::Form::Media',
        form_template      => 'media/form.tt',
        actions            => {
            base => {
                PathPart    => 'media',
                Chained     => '/exercises/base_with_id',
                CaptureArgs => 0,
            },
        },
    );

=head1 DESCRIPTION

CatalystX::TraitFor::Controller::Resource enhances the consuming Controller with CRUD 
functionality. It supports nested Resources and File Uploads.

=head1 File Upload

    if your form includes a file upload you have to
    set the file param so HTML::FormHandler can work its magic
    (e.g.: in the Controller consuming this role)

        before 'form' => sub {
            my ( $self, $c, $resource ) = @_;
            if ($c->req->method eq 'POST') {
                $c->req->params->{'file'} = $c->req->upload('file');
            }
        };

=head1 ATTRIBUTES

=head2 model

required, the DBIC model associated with this resource. (e.g.: 'DB::CDs')

=cut

has 'model' => (
    is => 'ro',
    required => 1,
);

=head2 resultset_key

stash key used to store the resultset of this resource. (e.g.: 'cds_rs')
defaults to 'resultset'

=cut

has 'resultset_key' => (
    is => 'ro',
    default => 'resultset',
);


=head2 resources_key

stash key used to store all results of this resource. (e.g.: 'tracks')
defaults to 'resources'.
You will need this in your template.

=cut

has 'resources_key' => (
    is => 'ro',
    default => 'resources',
);

=head2 resource_key

stash key used to store specific result of this resource. (e.g.: 'track')
defaults to 'resource'.
You will need this in your template.

=cut

has 'resource_key' => (
    is => 'ro',
    default => 'resource',
);

=head2 parent_key

for a nested resource 'parent_key' is used as stash key to store the parent item
(e.g.: 'cd')

=cut

has 'parent_key' => (
    is => 'ro',
    predicate => 'has_parent',
);

=head2 parents_accessor

the accessor on the parent resource to get a resultset
of this resource (accessor in DBIC has_many)
(e.g.: 'tracks')
this is required if parent_key is set

=cut

has 'parents_accessor' => (
    is => 'ro',
);

=head2 form_class

HTML::FormHandler class to use for this resource. 
defaults to 'CatalystX::Form::Resources'

=cut

has 'form_class' => (
    is => 'ro',
    default => 'Physio::Form::Resources',
);

=head2 form_template

template file for HTML::FormHandler
defaults to 'resources/form.tt'

=cut

has 'form_template' => (
    is => 'ro',
    default => 'resources/form.tt',
);

=head2 activate_fields_create

hashref of form fields to activate in the create form
e.g. ['password', 'password_confirm']
default = []

=cut

has 'activate_fields_create' => (
    is => 'ro',
    default => sub {[]},
);

=head2 activate_fields_edit

hashref of form fields to activate in the edit form
default = []

=cut
has 'activate_fields_edit' => (
    is => 'ro',
    default => sub {[]},
);

# path: /parents/1/resources/create   => redirect_path: /parents/1/resources
# path: /parents/1/resources/3/edit   => redirect_path: /parents/1/resources
# path: /parents/1/resources/3/delete => redirect_path: /parents/1/resources
sub _redirect_to_index {
    my ($self, $c) = @_;
    my @path_elements = split('/', $c->req->path);
    my $last = $#path_elements;
    my $path_element = $path_elements[$#path_elements];
    if ('create' eq $path_element) {
        $last -= 1;
    }
    elsif ('edit' eq $path_element) {
        $last -= 2;
    }
    # for custom edit like edit_file, edit_password, ...
    elsif ($path_element =~ m/^edit\w+/) {
        $last -= 2;
    }
    elsif ('delete' eq $path_element) {
        $last -= 2;
    }
    my @index_path_elements = @path_elements[0 .. $last];
    my $path = '/' . join('/', @index_path_elements);
    $c->res->redirect($path);
}

=head1 PATHS

the following paths will be loaded

=cut

sub base :Chained('') :PathPart('resources') :CaptureArgs(0) {
    my ($self, $c ) = @_;
    # Store the ResultSet in stash so it's available for other methods
    # get the model from the controllers config that consumes this role
    if($self->has_parent) {
        my $method = $self->parents_accessor;
        $c->stash($self->resultset_key => scalar $c->stash->{$self->parent_key}->$method);
    } else {
        $c->stash($self->resultset_key => $c->model($self->model));
    }
};

sub base_with_id :Chained('base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $id ) = @_;
    my $resource = $c->stash->{$self->resultset_key}->find($id);
    if ($resource) {
        $c->stash->{$self->resource_key} = $resource;
    } else {
        $c->stash(error_msg => "No such resource: " . $id);
        $c->detach('/error404');
    }
}

=head2 index

a list of all resources is accessible as $c->stash->{resources}

=cut

sub index :Chained('base') :PathPart('') :Args(0) {
    my ($self, $c ) = @_;
    $c->stash($self->resources_key => [ $c->stash->{$self->resultset_key}->all ]);
}

=head2 show

the resource specified by its id is accessible as $c->stash->{resource}

=cut

sub show :Chained('base_with_id') :PathPart('show') :Args(0) {
    my ($self, $c ) = @_;
}

=head2 create

create a resource

=cut

sub create :Chained('base') :PathPart('create') :Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{$self->resultset_key}->new_result({});
    return $self->form($c, $resource, $self->activate_fields_create);
}

=head2 delete

delete a specific resource

=cut

sub delete :Chained('base_with_id') :PathPart('delete') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{$self->resource_key}->delete($c);
    $c->flash(msg => 'Resource deleted');
    $self->_redirect_to_index($c);
}

=head2 edit

edit a specific resource

=cut

sub edit : Chained('base_with_id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;
    return $self->form($c, $c->stash->{$self->resource_key}, $self->activate_fields_edit);
}

# $activate_fields is a hashref with fields to activate
# this provides a hook so you can use moose method modifiers
# in the consuming controller using "around 'form'" and adding
# the hashref in $self->$orig(@_, ['activate_this_field']);
sub form {
    my ( $self, $c, $resource, $activate_fields ) = @_;

    # HFH clears the arrayref
    my $form = $self->form_class->new(active => [@$activate_fields]);

    $c->stash( template => $self->form_template, form => $form );

    $form->process(
        item    => $resource, 
        params  => $c->req->params,
    );

    return unless $form->validated;  
    $c->flash(msg => 'Resource created/edited');
    $self->_redirect_to_index($c);
}

=head1 AUTHOR

=over

=item David Schmidt (davewood) C<< <davewood@gmx.at> >>

=back

=head1 LICENSE

Copyright 2010 David Schmidt. Some rights reserved.

This software is free software and is licensed under the same terms as perl itself.

=cut

1;
