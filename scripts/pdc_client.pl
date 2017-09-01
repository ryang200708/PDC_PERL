#!/usr/bin/perl
#use strict;
use warnings;
use REST::Client;
use JSON;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Text::ASCIITable;

sub usage {
    my $usage = <<END;
Usage: pdc_client.pl [OPTION]
       OPTIONS := { -v[ersion] | -r resource | -s search }
END
}

sub get_resource_page {
    my ($resource) = @_;
    my $tmp_result = get_resource_server($resource);
    my $next       = $tmp_result->{'next'};
    my $arrayref   = $tmp_result->{'results'};
    if ( !$next and !$arrayref ) { return $tmp_result }
    if ($next) {
        my $next_arrayref = get_resource_page($next);
        foreach my $t (@$next_arrayref) {
            push( @$arrayref, $t );
        }
        return $arrayref;
    }
    else {
        return $arrayref;
    }
}

sub get_resource_server {
    my ($resource) = @_;
    my $headers = {
        Accept        => 'application/json',
        Authorization => 'Token 90feef8b2d2fcd4d2073d6e46640ea1e55cc02ad'
    };
    my $client = REST::Client->new();
    $client->GET( $resource, $headers );
    my $code    = $client->responseCode;
    my $content = from_json( $client->responseContent() );
    if ( $code == 200 ) {
        return ($content);
    }
    else {
        if ( $content->{'detail'} ) {
            print from_json( $client->responseContent() )->{'detail'};
            print "\n";
            exit 1;
        }
    }
}

#TODO pring need support more complex format
sub print_resource {
    my ( $title, $ref ) = @_;
    my $t = Text::ASCIITable->new( { headingText => $title } );
    if ( ref($ref) eq "HASH" ) {
        $t->setCols( "Resource", "url" );
        foreach my $key ( keys %$ref ) {
            $t->addRow( $key, $ref->{$key} );
        }
    }
    elsif ( ref($ref) eq "ARRAY" ) {
        my @keys = sort ( keys %{ ${$ref}[0] } );
        $t->setCols(@keys);
        foreach my $tt (@$ref) {
            my @row;
            foreach my $ttt (@keys) {
                push( @row, $tt->{$ttt} );
            }
            $t->addRow(@row);
        }
    }
    print $t;
}

sub main {
    my $help = 0;
    my $para;
    $para->{host}     = "https://pdc.engineering.redhat.com/";
    $para->{resource} = '';
    $para->{search}   = '';
    $para->{version}  = 1;
    GetOptions(
        "h=s"  => \$para->{host},
        "r=s"  => \$para->{resource},
        "s=s"  => \$para->{search},
        "v=i"  => \$para->{version},
        "help" => \$help,
    ) or pod2usage( { -message => usage } );

    if ( @ARGV > 0 ) {
        pod2usage( { -message => usage } );
    }
    else {
        my $url = $para->{host} . "rest_api/v" . $para->{version} . "/";
        if ( $para->{resource} ) { $url .= $para->{resource} . "/"; }
        if ( $para->{search} )   { $url .= "?" . $para->{search}; }
        my $arrayref = get_resource_page($url);
        print_resource( $url, $arrayref );
        exit 0;
    }

}
&main;
