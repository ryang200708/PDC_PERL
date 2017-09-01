package PDC::ReleaseVariant;

use warnings;
use strict;
use PDC::ReleaseType;
use PDC::RestClient;
use PDC::Util;

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

sub _check_name {
    return 1;
}

sub _check_short {
    return 1;
}

sub _check_version {
    return 1;
}

sub _check_base_product_id {
    return 1;
}

=head2 init_with_base_product_id

=cut

sub init_with_base_product_id {
    my $self = shift;
    if ( !exists( $self->{'base_product_id'} ) ) {
        print "'base_product_id' is required\n";
        return 0;
    }
    return $self->init_with_search(
        "base_product_id=" . $self->{'base_product_id'} );
}

=head2 init_with_search

=cut

sub init_with_search {
    my $self     = shift;
    my ($search) = @_;
    my $t        = search( ( 'base-products', $search ) );
    if ($t) {
        return $self->_init_s1($t);
    }
    else {
        return 0;
    }
}

sub _init_s2 {
    my $self   = shift;
    my $search = '';
    $search .= "base_product_id=" . $self->{'base_product_id'}
      if ( exists( $self->{'base_product_id'} ) );
    $search .= "&short=" . $self->{'short'} if ( exists( $self->{'short'} ) );
    $search .= "&name=" . $self->{'name'}   if ( exists( $self->{'name'} ) );
    $search .= "&version=" . $self->{'version'}
      if ( exists( $self->{'version'} ) );
    return $self->init_with_search($search);
}

# set values to object
sub _init_s1 {
    my $self = shift;
    my ($handle) = @_ if ( scalar @_ );
    if ( defined($handle) ) {
        while ( my @pair = each(%$handle) ) {
            if ( defined( $pair[1] ) ) {
                if ( $pair[0] eq "name" ) {
                    $self->{'name'} = $pair[1]
                      if ( _check_name( $pair[1] ) );
                }
                elsif ( $pair[0] eq "short" ) {
                    $self->{'short'} = $pair[1]
                      if ( _check_short( $pair[1] ) );
                }
                elsif ( $pair[0] eq "version" ) {
                    $self->{'version'} = $pair[1]
                      if ( _check_version( $pair[1] ) );
                }
                elsif ( $pair[0] eq "base_product_id" ) {
                    $self->{'base_product_id'} = $pair[1]
                      if ( _check_base_product_id( $pair[1] ) );
                }
                elsif ( $pair[0] eq "release_type" ) {
                    $self->{'release_type'} =
                      PDC->new_release_type( { short => $pair[1] } );
                }
                else {
                    $self->{"$pair[0]"} = $pair[1];
                }
            }
        }
    }
    return 1;
}

sub _init {
    my $self = shift;
    my ($handle) = @_ if ( scalar @_ );
    $self->_init_s1($handle);
    if ( $self->_init_s2 ) {
        return $self;
    }
    else {
        print "Object creation failed\n";
        return 0;
    }
}

=head2 new

create instance

=cut

sub new {
    my $self  = shift;
    my $class = ref($self) || $self;
    my $this  = {};
    bless $this, $class;
    return $this->_init(@_);
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

1;    #End of PDC::ReleaseVariant
