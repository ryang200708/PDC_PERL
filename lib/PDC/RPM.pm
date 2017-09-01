package PDC::RPM;

use warnings;
use strict;
use PDC::RestClient;

=head1 NAME

PDC::RPM

=head1 SYNOPSIS

    use PDC::RPM;

Method: GET

URL: /rest_api/v1/rpms/

Query params:

    arch (string)
    built_for_release (string)
    compose (string)
    conflicts (string)
    epoch (int)
    filename (string)
    has_no_deps (bool)
    linked_release (string)
    name (regular expression)
    obsoletes (string)
    provides (string)
    recommends (string)
    release (string)
    requires (string)
    srpm_name (string)
    srpm_nevra (string | null)
    suggests (string)
    version (string)
    ordering is used to override the ordering of the results, the value could be: ['name', 'srpm_name', 'filename', 'srpm_nevra', 'epoch', 'version', 'release', 'built_for_release', 'arch', u'id'] .

If the has_no_deps filter is used, the output will only contain RPMs which have some or do not have any dependencies.

All the dependency filters use the same data format.

The simpler option is just name of the dependency. In that case it will filter RPMs that depend on that given name.

The other option is an expression NAME OP VERSION. This will filter all RPMs that have a dependency on NAME such that adding this constraint will not make the package dependencies inconsistent.

For example filtering by python=2.7.0 would include packages with dependency on python=2.7.0, python>=2.6.0, python<3.0.0, but exclude python=2.6.0. Filtering by python<3.0.0 would include packages with python>2.7.0, python=2.6.0, python<3.3.0, but exclude python>3.1.0 or python>3.0.0 && python <3.3.0.

Only single filter for each dependency type is allowed.

Multiple name regular expressions which will be OR-ed. Preferably use OR inside the regexp.

Response: a paged list of following objects

{
    "arch": "string",
    "built_for_release (optional, default=null, nullable)": "Release.release_id",
    "dependencies (optional, default={})": {
        "conflicts": [
            "string"
        ],
        "obsoletes": [
            "string"
        ],
        "provides": [
            "string"
        ],
        "recommends": [
            "string"
        ],
        "requires": [
            "string"
        ],
        "suggests": [
            "string"
        ]
    },
    "epoch": "int",
    "filename (optional, default=\"{name}-{version}-{release}.{arch}.rpm\")": "string",
    "id (read-only)": "int",
    "linked_composes (read-only)": [
        "compose_id"
    ],
    "linked_releases (optional, default=[])": [
        "Release.release_id"
    ],
    "name": "string",
    "release": "string",
    "srpm_name": "string",
    "srpm_nevra (optional, default=null)": "string",
    "version": "string"
}

=head1 FUNCTIONS

=cut

sub refresh {
    my $self = shift;
    $self->_clean;
    my $rest_client = PDC::RestClient->new( { resource => 'rpms' } );
    my $result = $rest_client->retrieve( $self->getId );
    if ( $result->{'code'} == 200 ) {
        my $hashref = $result->{'content'};
        foreach my $key ( keys(%$hashref) ) {
            $self->{$key} = $hashref->{$key};
        }
    }
    else {
        $self->{'error'} =
          { code => $result->{'code'}, content => $result->{'content'} };
    }
    return $self;
}

sub _clean {
    my $self = shift;
    foreach my $key ( keys %$self ) {
        delete $self->{$key} if ( $key ne 'id' );
    }
}

=head2 error

=cut

sub error {
    my $self = shift;
    return $self->{'error'} || undef;
}

sub _buildAccessors {
    my $self = shift;

    return if $self->can('setId');

    my @attributes = qw(Id);

    for my $attribute (@attributes) {
        my $set_method = "
        sub {
        my \$self = shift;
        \$self->{lc('$attribute')} = shift;
        return \$self->{lc('$attribute')};
        }";

        my $get_method = "
        sub {
        my \$self = shift;
        return \$self->{lc('$attribute')};
        }";

        {
            no strict 'refs';
            *{ 'PDC::RPM::set' . $attribute } = eval $set_method;
            *{ 'PDC::RPM::get' . $attribute } = eval $get_method;
        }

    }
    return;
}

=head2 new

create instance

=cut

sub new {
    my $class = shift;
    my ($id) = (@_) if (@_);
    $class->_buildAccessors();

    if ( defined $id and !ref($id) and $id ) {
        my $self = bless( {}, $class );
        $self->setId($id);
        $self->refresh;
        return $self;
    }
    else {
        return undef;
    }
}

=head1 AUTHOR

Yang,Ren, C<< <ryang at redhat.com> >>

=head1 BUGS

For any issue please email ryang@redhat.com

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PDC::BaseProduct


You can also look for information at docs folder in source code.

=head1 COPYRIGHT & LICENSE

Copyright 2017 Yang,Ren.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    #End of PDC::RPM
