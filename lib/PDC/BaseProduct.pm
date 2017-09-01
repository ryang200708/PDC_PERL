package PDC::BaseProduct;

use warnings;
use strict;
use PDC::ReleaseType;
use PDC::RestClient;

=head1 NAME

PDC::BaseProduct - the module used to generate base products objective

=head1 SYNOPSIS

    use PDC::BaseProduct;

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
    my $result = $rest_client->retrieve( $self->getBase_product_id );
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
    my $self               = shift;
    my $release_type_short = $self->{'release_type'};
    $self->{'release_type'} = PDC::ReleaseType->new($release_type_short);
    return;
}

=head2 fill 

=cut

sub fill {
    my $self               = shift;
    my $release_type_short = $self->{'release_type'}->{short};
    $self->{'release_type'} = $release_type_short;
    return;
}

sub _clean {
    my $self = shift;
    foreach my $key ( keys %$self ) {
        delete $self->{$key} if ( $key ne 'base_product_id' );
    }
}

=head2 error 

=cut 

sub error {
    my $self = shift;
    return $self->{'error'} || undef;
}

=head2 search_releases

=cut 

sub search_releases {

}

=head2 check_exists 

=cut

sub check_exists {
    my $self            = shift;
    my $base_product_id = $self->getBase_product_id;
    my $product_version = PDC::ProductVersion->new($base_product_id);
    my $release         = PDC::Release->new($base_product_id);

    my $tag = 0;
    if ( !$product_version->error ) {
        $tag++;
        print "$base_product_id: ProductVersion exist\n";
    }
    if ( !$release->error ) {
        $tag++;
        print "$base_product_id: Release exist\n";
    }
    if ( !$tag ) {
        print "$base_product_id: No ProductVersion or Release\n";
    }
    return;
}

sub _buildAccessors {
    my $self = shift;

    return if $self->can('setBase_product_id');

    my @attributes = qw(Base_product_id);

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
            *{ 'PDC::BaseProduct::set' . $attribute } = eval $set_method;
            *{ 'PDC::BaseProduct::get' . $attribute } = eval $get_method;
        }

    }

    return;
}

=head2 new

create instance

=cut

sub new {
    my $class = shift;
    my ($base_product_id) = (@_) if (@_);
    $class->_buildAccessors();

    if (    defined $base_product_id
        and !ref($base_product_id)
        and $base_product_id )
    {
        my $self = bless( {}, $class );
        $self->setBase_product_id($base_product_id);
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

1;    #End of PDC::BaseProduct
