package PDC::ProductVersion;

use warnings;
use strict;
use PDC::RestClient;
use PDC::Release;

=head1 NAME

PDC::ProductVersion

=head1 SYNOPSIS

    use PDC::ProductVersion;

Method: GET

URL: /rest_api/v1/product-versions/

Query params:

    active (bool)
    name (string)
    product_version_id (string)
    short (string)
    version (string)
    ordering is used to override the ordering of the results, the value could be: ['version', 'product', 'short', 'name', 'product_version_id'] .

Response: a paged list of following objects

{
    "active (read-only)": "boolean", 
    "name": "string", 
    "product": "Product.short", 
    "product_version_id (read-only)": "string", 
    "releases (read-only)": "[release_id]", 
    "short": "string", 
    "version": "string"
}

=head1 FUNCTIONS

=cut

sub refresh {
    my $self = shift;
    $self->_clean;
    my $rest_client =
      PDC::RestClient->new( { resource => 'product-versions' } );
    my $result = $rest_client->retrieve( $self->getProduct_version_id );
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
    my $release_id_arrayref = $self->{'releases'};
    foreach my $release_id (@$release_id_arrayref) {
        push( @array, PDC::Release->new($release_id) );
    }
    $self->{'releases'} = \@array;
    return;
}

=head2 fill

=cut

sub fill {
    my $self = shift;
    my @array;
    my $release_obj_arrayref = $self->{'releases'};
    foreach my $release_obj (@$release_obj_arrayref) {
        push( @array, $release_obj->{'release_id'} );
    }
    $self->{'releases'} = \@array;
    return;
}

sub _clean {
    my $self = shift;
    foreach my $key ( keys %$self ) {
        delete $self->{$key} if ( $key ne 'product_version_id' );
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

    return if $self->can('setProduct_version_id');

    my @attributes = qw(Product_version_id);

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
            *{ 'PDC::ProductVersion::set' . $attribute } = eval $set_method;
            *{ 'PDC::ProductVersion::get' . $attribute } = eval $get_method;
        }

    }

    return;
}

=head2 new

create instance

=cut

sub new {
    my $class = shift;
    my ($product_version_id) = (@_) if (@_);
    $class->_buildAccessors();

    if (    defined $product_version_id
        and !ref($product_version_id)
        and $product_version_id )
    {
        my $self = bless( {}, $class );
        $self->setProduct_version_id($product_version_id);
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

1;    #End of PDC::ProductVersion
