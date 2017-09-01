package PDC::Product;

use warnings;
use strict;
use PDC::ProductVersion;
use PDC::RestClient;

=head1 NAME

PDC::Product 

=head1 SYNOPSIS

    use PDC::Product;

Method: GET

URL: /rest_api/v1/products/

Query params:

    active (bool)
    internal (bool)
    name (string)
    short (string)
    ordering is used to override the ordering of the results, the value could be: ['short', 'name'] .

Response: a paged list of following objects

{
    "active (read-only)": "boolean",
    "internal (optional, default=false)": "boolean",
    "name": "string",
    "product_versions (read-only)": [
        "product_version_id"
    ],
    "short": "string"
}

=head1 FUNCTIONS

=cut

=head2 refresh

=cut

sub refresh {
    my $self = shift;
    $self->_clean;
    my $rest_client = PDC::RestClient->new( { resource => 'products' } );
    my $result = $rest_client->retrieve( $self->getShort );
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

=head2 dig

=cut

sub dig {
    my $self = shift;
    my @array;
    my $product_version_id_arrayref = $self->{'product_versions'};
    foreach my $product_version_id (@$product_version_id_arrayref) {
        push( @array, PDC::ProductVersion->new($product_version_id) );
    }
    $self->{'product_versions'} = \@array;
    return;
}

=head2 fill

=cut

sub fill {
    my $self = shift;
    my @array;
    my $release_obj_arrayref = $self->{'product_versions'};
    foreach my $release_obj (@$release_obj_arrayref) {
        push( @array, $release_obj->{'product_version_id'} );
    }
    $self->{'product_versions'} = \@array;
    return;
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
            *{ 'PDC::Product::set' . $attribute } = eval $set_method;
            *{ 'PDC::Product::get' . $attribute } = eval $get_method;
        }

    }

    return;
}

=head2 new

create instance

=cut

sub new {
    my $class = shift;
    my ($short) = (@_) if (@_);
    $class->_buildAccessors();

    if ( defined $short and !ref($short) and $short ) {
        my $self = bless( {}, $class );
        $self->setShort($short);
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

1;    #End of PDC::Product
