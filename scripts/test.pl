BEGIN {
    #    unshift(@INC, '/homg/ryang/PDC/');
    #unshift(@INC, '/homg/ryang/PDC/PDC/');
}
use strict;
use Data::Dumper;
use Data::TreeDumper;
use Text::ASCIITable;

use PDC;
use PDC::BaseProduct;
use PDC::BaseProducts;
use PDC::Product;
use PDC::Products;
use PDC::ProductVersion;
use PDC::ProductVersions;
use PDC::Release;
use PDC::Releases;
use PDC::RestClient;
use PDC::RPM;
use REST::Client;

=head1 URI
my $str = 'https://pdc.engineering.redhat.com/rest_api/v1/base-products/?base_product_id=rhel-5.4-eus#tab_update';
my $uri = URI->new( $str );
#print Dumper $uri->scheme, $uri->path, $uri->fragment, $uri->authority;
#print Dumper $uri->path_query, $uri->path_segments, $uri->query;

#print Dumper $uri->path_segments;
print Dumper $uri->query;
=cut

=head1 test
my $rest_client = PDC::RestClient->new(
    {
        host        => "https://pdc.engineering.redhat.com/",
        resource    => 'base-products',
        api_version => 'v1',
        search      => { short => 'rhel' },
        unique      => 'rhel-5.4-eus'
    }
);

my $rest_client1 = PDC::RestClient->new();

#print Dumper $rest_client->list({base_product_id => 'rhel-4.7-eus'});
print Dumper $rest_client->retrieve('rhel-4.7-eus');

#print Dumper $rest_client->retrieve('re');

=cut

=head1 release_type_testing

my $release_type = PDC->new_release_type('ga');
print Dumper $release_type;

$release_type->setShort('gaa');
$release_type->refresh;
print Dumper $release_type;

=cut

=head1 base_product_test

my $base_product = PDC->new_base_product('rhel-2.2');
print Dumper $base_product;

$base_product->setBase_product_id('rhel-5.2-eus');
$base_product->refresh;
print Dumper $base_product;
$base_product->dig;
print Dumper $base_product;
$base_product->fill;
print Dumper $base_product;

#print Dumper $base_product->check_exists;

#$base_product->setBase_product_id('rhel-dddd5.2-eus');
#$base_product->refresh;
#print Dumper $base_product;

=cut

=head1 test for PDC::BaseProducts

my $base_products =
  PDC::BaseProducts->new( { short => 'rhel', version => '7' } );
print Dumper $base_products;
$base_products->setSearch( { short => 'rhel', version => '6' } );
print Dumper $base_products;
$base_products->refresh;
print Dumper $base_products;

=cut

=head1 test for checkBaseProduct existed

my $base_products = PDC::BaseProducts->new();
print Dumper $base_products;

my $arrayref = $base_products->{'content'};
foreach my $hashref (@$arrayref) {
    my $base_product = PDC::BaseProduct->new( $hashref->{base_product_id} );
    $base_product->check_exists;
}

#print Dumper $base_products;

=cut

=head1 product test

#my $product = PDC->new_product('ceph');
my $product = PDC->new_product('rhel');
print Dumper $product;
$product->dig;
print Dumper $product;
$product->fill;
print Dumper $product;

=cut

=head1 ProductVersion test

#error return undef
my $product_version = PDC->new_product_version('amq-interconnect-1');

#$product_version->setProduct_version_id( { abc => 'abc' } );
$product_version->setProduct_version_id('abc');
$product_version->refresh;

$product_version->setProduct_version_id('ceph-1');
$product_version->refresh;

print Dumper $product_version;
$product_version->dig;
print Dumper $product_version;
$product_version->fill;
print Dumper $product_version;

=cut

=head1 release

#my $release1 = PDC->new_release( { release_id => 'ceph-2.1@rhel-7' } );
my $release = PDC->new_release('rhel-7.4');
print Dumper $release;

$release->setRelease_id('ceph-2.1@rhel-7');
$release->refresh;
print Dumper $release;

=cut

=head1 test for Products ProductVersions Releases

my $releases = PDC::Releases->new( { base_product => 'rhel-7' } );
my $result_arrayref = $releases->Content;
print scalar(@$result_arrayref) . " Releases has base_product 'rhel-7':\n";
foreach my $hash (@$result_arrayref) {
    print $hash->{'release_id'} . "\n";
}
print "\n";
$releases->setSearch( { base_product => 'rhel-6' } );
$releases->refresh;
$result_arrayref = $releases->Content;
print scalar(@$result_arrayref) . " Releases has base_product 'rhel-6':\n";
foreach my $hash (@$result_arrayref) {
    print $hash->{'release_id'} . "\n";
}

=cut

=head1 test for check different release_types


my $releases = PDC::Releases->new( { release_type => 'ga' } );
my $result_arrayref = $releases->Content;
print scalar(@$result_arrayref) . " Releases has release_type 'ga':\n";

=cut

=head1 test print all active product short:name

my $products = PDC::Products->new({ active => 'true', internal => 'false' });
my $result_arrayref = $products->Content;

my $t = Text::ASCIITable->new( { headingText => "Products" } );
$t->setCols( "Short", "Name" );
foreach my $product (@$result_arrayref) {
    $t->addRow( $product->{short}, $product->{name} );
}
print $t;

=cut

=head1 test print product rhel and product_version rhel7-4

my $product = PDC::Product->new('ceph');
$product->dig;
my $product_versions_arrayref = $product->{product_versions};
foreach my $product_version (@$product_versions_arrayref) {
    $product_version->dig;
}
#print DumpTree($product);
print Dumper $product;

=cut

#=head1 rpm 429840

my $rpm = PDC::RPM->new('429840');
#print DumpTree $rpm;
my $compose = PDC::Compose->new('RHEL-7.4-20170710.0');
#print DumpTree $compose;
my $release = PDC::Release->new($compose->{'release'});
#print DumpTree $release;
my $product_version = PDC::ProductVersion->new($release->{'product_version'});
#print DumpTree $product_version;
my $product = PDC::Product->new($product_version->{'product'});
#print DumpTree $product;

delete($compose->{'rtt_tested_architectures'});
delete($product->{'product_versions'});
$product_version->{'product'} = $product;
delete($product_version->{'releases'});
$release->{'product_version'} = $product_version;
delete($release->{'compose_set'});
$compose->{'release'} = $release;
$rpm->{'compose'} = $compose;
delete($rpm->{'linked_composes'});
#print DumpTree $rpm;
print Dumper $rpm;

#=cut
