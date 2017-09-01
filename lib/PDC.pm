package PDC;

use warnings;
use strict;

use PDC::RestClient;
use PDC::BaseProduct;
use PDC::Product;
use PDC::ProductVersion;
use PDC::Release;
use PDC::ReleaseType;
use PDC::Compose;
use PDC::ReleaseVariant;
use PDC::ReleaseVariantType;
use PDC::Util;

=head1 NAME

PDC - the entry of PDC module.

=head1 VERSION

Version 1.0

=cut

our $VERSION = 0.1;

=head1 SYNOPSIS

    use PDC;

    my $base_product = PDC->new_base_product({'base_product_id' => 'dp-1'});
    ...

=head1 FUNCTIONS

=head2 new_base_product

Creat base product objectives 

=cut

sub new_base_product {
    my $class = shift;
    my ($handle) = @_ if ( scalar @_ );
    return new PDC::BaseProduct($handle);
}

=head2 new_product

Creat product objectives

=cut

sub new_product {
    my $class = shift;
    my ($handle) = @_ if ( scalar @_ );
    return new PDC::Product($handle);
}

=head2 new_product_version

Creat product version objectives 

=cut

sub new_product_version {
    my $class = shift;
    my ($handle) = @_ if ( scalar @_ );
    return new PDC::ProductVersion($handle);
}

=head2 new_release

=cut

sub new_release {
    my $class = shift;
    my ($handle) = @_ if ( scalar @_ );
    return new PDC::Release($handle);
}

=head2 new_release_type

=cut

sub new_release_type {
    my $class = shift;
    my ($handle) = @_ if ( scalar @_ );
    return new PDC::ReleaseType($handle);
}

=head2 new_compose

=cut

sub new_compose {
    my $class = shift;
    my ($handle) = @_ if ( scalar @_ );
    return new PDC::Compose($handle);
}

=head2 new_release_variant

=cut

sub new_release_variant {
    my $class = shift;
    my ($handle) = @_ if ( scalar @_ );
    return new PDC::ReleaseVariant($handle);
}

=head2 new_release_variant_type

=cut

sub new_release_variant_type {
    my $class = shift;
    my ($handle) = @_ if ( scalar @_ );
    return new PDC::ReleaseVariantType($handle);
}

=head1 AUTHOR

Yang,Ren, C<< <ryang at redhat.com> >>

=head1 BUGS

For any issue please email ryang@redhat.com

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PDC


You can also look for information at docs folder in source code.

=head1 COPYRIGHT & LICENSE

Copyright 2017 Yang,Ren.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of PDC
