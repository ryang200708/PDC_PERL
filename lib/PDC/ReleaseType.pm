package PDC::ReleaseType;

use warnings;
use strict;
use PDC::Util;
use PDC::RestClient;
use Data::Dumper;

=head1 NAME

PDC::ReleaseType 

=head1 SYNOPSIS

    Method: GET

    URL: /rest_api/v1/release-types/

    Query params:

        name (string, case insensitive, substring match)
        short (string)
        ordering is used to override the ordering of the results, the value could be: ['short', 'name', 'suffix'] .

    Response: a paged list of following objects

    {
        "name": "string", 
        "short": "string", 
        "suffix": "string"
    }

=head1 FUNCTIONS

=head2 refresh

=cut 

sub refresh {
    my $self = shift;
    $self->_clean;
    my $rest_client = PDC::RestClient->new( { resource => 'release-types' } );
    my $result = $rest_client->list( { short => $self->getShort } );
    if ( $result->{'code'} == 200 and $result->{content}->{'count'} == 1 ) {
        my $aref    = $result->{content}->{'results'};
        my $hashref = shift @$aref;
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
        delete $self->{$key} if ( $key ne 'short' );
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

    return if $self->can('setShort');

    my @attributes = qw(Short);

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
            *{ 'PDC::ReleaseType::set' . $attribute } = eval $set_method;
            *{ 'PDC::ReleaseType::get' . $attribute } = eval $get_method;
        }

    }

    return;
}

=head2 new

create instance

=cut

sub new {
    my $class = shift;

#there is no retrieve method for release-types in PDC v1 restAPI
#Here I assume short is the unique in base_products "release_type": "ReleaseType.short",
    my ($short) = (@_) if (@_);
    $class->_buildAccessors();

    if ( defined $short and $short ) {
        my $self = bless( {}, $class );
        $self->setShort($short);
        return $self->refresh;
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

1;    #End of PDC::ReleaseType
