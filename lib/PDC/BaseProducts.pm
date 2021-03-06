package PDC::BaseProducts;

use warnings;
use strict;
use PDC::ReleaseType;
use PDC::BaseProduct;
use PDC::RestClient;

=head1 NAME

PDC::BaseProducts - the module used to generate base products objective

=head1 SYNOPSIS

    use PDC::BaseProducts;

    my $base_product = PDC::BaseProduct->new({'base_product_id' => dp-1});
    ...

Method: GET

URL: /rest_api/v1/base-products/

Query params:

    base_product_id (string)
    name (string)
    short (string)
    version (string)
    ordering is used to override the ordering of the results, the value could be: ['name', 'short', 'version', 'release_type', 'base_product_id'] .

Response:

{
    "base_product_id (read-only)": "string",
    "name": "string",
    "release_type": "ReleaseType.short",
    "short": "string",
    "version": "string"
}

=head1 FUNCTIONS

=cut

=head2 refresh

=cut

sub refresh {
    my $self = shift;
    $self->_clean;
    my $rest_client = PDC::RestClient->new( { resource => 'base-products' } );
    my $result = $rest_client->list( $self->getSearch );
    if ( $result->{'code'} == 200 ) {

      #        my @array;
      #        my $aref = $result->{content}->{'results'};
      #        foreach my $hashref (@$aref) {
      #            push( @array,
      #                PDC::BaseProduct->new( $hashref->{'base_product_id'} ) );
      #        }
      #        $self->{'content'} = \@array;
        $self->{'content'} = $result->{content}->{'results'};
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
        delete $self->{$key} if ( $key ne 'search' );
    }
}

=head2 Content

=cut

sub Content {
    my $self = shift;
    return $self->{'content'} || undef;
}

=head2 error 

=cut

sub error {
    my $self = shift;
    return $self->{'error'} || undef;
}

sub _buildAccessors {
    my $self = shift;

    return if $self->can('setSearch');

    my @attributes = qw(Search);

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
            *{ 'PDC::BaseProducts::set' . $attribute } = eval $set_method;
            *{ 'PDC::BaseProducts::get' . $attribute } = eval $get_method;
        }

    }

    return;
}

=head2 new

create instance

=cut

sub new {
    my $class  = shift;
    my $search = {};
    if ( ref $_[0] eq 'HASH' ) {
        $search = shift;
    }

    $class->_buildAccessors();

    my $self = bless( {}, $class );
    $self->setSearch($search);
    return $self->refresh;
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

1;    #End of PDC::BaseProducts
