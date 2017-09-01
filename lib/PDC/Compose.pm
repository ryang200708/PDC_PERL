package PDC::Compose;

use warnings;
use strict;
use PDC::RestClient;

=head1 NAME

PDC::Compose

=head1 SYNOPSIS

    use PDC::Compose;

Method: GET

URL: /rest_api/v1/composes/

Query params:

    acceptance_testing (string)
    compose_date (string)
    compose_id (string)
    compose_label (string)
    compose_respin (string)
    compose_type (string)
    deleted (bool)
    release (string)
    rpm_arch
    rpm_name
    rpm_nvr (string)
    rpm_nvra (string)
    rpm_release
    rpm_version
    srpm_name
    ordering is used to override the ordering of the results, the value could be: ['compose_label', 'deleted', 'compose_respin', 'compose_date', 'compose_type', 'release', 'acceptance_testing', 'compose_id'] .

Response: a paged list of following objects

{
    "acceptance_testing": "ComposeAcceptanceTestingState.name", 
    "compose_date": "date", 
    "compose_id": "string", 
    "compose_label (nullable)": "string", 
    "compose_respin": "int", 
    "compose_type": "string", 
    "deleted (optional, default=false)": "boolean", 
    "linked_releases": [
        "Release.release_id"
    ], 
    "release": "string", 
    "rpm_mapping_template (read-only)": "url", 
    "rtt_tested_architectures (read-only)": {
        "variant": {
            "arch": "testing status"
        }
    }, 
    "sigkeys (read-only)": [
        "string"
    ]
}

=head1 FUNCTIONS

=cut

sub refresh {
    my $self = shift;
    $self->_clean;
    my $rest_client = PDC::RestClient->new( { resource => 'composes' } );
    my $result = $rest_client->retrieve( $self->getCompose_id );
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
        delete $self->{$key} if ( $key ne 'compose_id' );
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

    return if $self->can('setCompose_id');

    my @attributes = qw(Compose_id);

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
            *{ 'PDC::Compose::set' . $attribute } = eval $set_method;
            *{ 'PDC::Compose::get' . $attribute } = eval $get_method;
        }

    }
    return;
}

=head2 new

create instance

=cut

sub new {
    my $class = shift;
    my ($compose_id) = (@_) if (@_);
    $class->_buildAccessors();

    if ( defined $compose_id and !ref($compose_id) and $compose_id ) {
        my $self = bless( {}, $class );
        $self->setCompose_id($compose_id);
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

1;    #End of PDC::Compose
