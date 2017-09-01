package PDC::RestClient;

use warnings;
use strict;

use URI;
use REST::Client;
use JSON;
use Data::Dumper;

=head1 NAME

PDC::RestClient - the module used to connect to PDC server

=head1 SYNOPSIS

PDC::RestClient give the ability to work with one PDC server about list, retrieve, create, update, bulk_create, bulk_update one resources
list,retrieve has been implemented and other functions are still in the air. 

The parameter to create this object is listed below

 
    $self->{host}             = "https://pdc.engineering.redhat.com/";
    $self->{resource}         = '';
    $self->{search}           = '';
    $self->{unique}           = '';
    $self->{api_version}      = 1;

Example:
use PDC::RestClient
my $rest_client = PDC::RestClient->new( {
    'host' => 'https://pdc.engineering.redhat.com/',
    'resource' => 'base-products', 
    'api_version' => 1, 
    'search => 'version=4.5'
});
my $list_ref = $rest_client->list;

=head1 FUNCTIONS

=head2 list

list function require the client object contain at least:
    host, resource, pdc_rest_version, search 

=cut

sub list {
    my $self = shift;
    $self->setSearch(@_) if ( scalar @_ );
    if ( $self->_check ) {
        if ( $self->_generate_uri('list') ) {
            my ( $code, $content ) = _get_page( $self->{uri} );
            $self->{'code'}    = $code;
            $self->{'content'} = $content;
        }
        else {
            $self->{'_error'} .= ":List Fail";
        }
    }
    return $self;
}

=head2 retrieve

list function require the client object contain at least:
    host, resource, api_version, unique

=cut

sub retrieve {
    my $self = shift;
    $self->setUnique(@_) if ( scalar @_ );
    if ( $self->_check ) {
        if ( exists $self->{'_config'}->{'unique'} ) {

            if ( $self->_generate_uri('retrieve') ) {
                my ( $code, $content ) = _get( $self->{uri} );
                $self->{'code'}    = $code;
                $self->{'content'} = $content;
            }
            else {
                $self->{'_error'} .= ":Retrieve Fail";
            }
        }
        else {
            $self->{'_error'} .= ":No Unique";
        }
    }
    return $self;
}

sub _generate_uri {
    my $self      = shift;
    my ($command) = @_;
    my $config    = $self->{'_config'};
    my $uri       = URI->new( $config->{host} );
    if (   $command eq 'list'
        or $command eq 'create'
        or $command eq 'bulk_create'
        or $command eq 'bulk_update' )
    {
        $uri->path_segments( '', 'rest_api', $config->{api_version},
            $config->{resource}, '' );
        $uri->query_form( $config->{search} ) if ( exists $config->{search} );
    }
    elsif ( $command eq 'retrieve' or $command eq 'update' ) {
        $uri->path_segments( '', 'rest_api', $config->{api_version},
            $config->{resource}, $config->{unique}, '' );
    }
    else {
        #impossible here
        $self->{'_error'} .= "not such command:$command;";
        return 0;
    }
    $self->{'uri'} = $uri->as_string;
    return 1;
}

sub _get {
    my ($resource) = @_ if ( scalar @_ );
    my $headers = {
        Accept        => 'application/json',
        Authorization => 'Token 90feef8b2d2fcd4d2073d6e46640ea1e55cc02ad'
    };
    my $client = REST::Client->new();
    $client->GET( $resource, $headers );
    return ( $client->responseCode,
        from_json( $client->responseContent(), { utf8 => 1, pretty => 1 } ) );
}

sub _get_page {
    my ($resource) = @_ if ( scalar @_ );
    my ( $code, $content ) = _get($resource);

    return ( $code, $content ) if ( !exists( $content->{'next'} ) );

    my $next            = $content->{'next'};
    my $result_arrayref = $content->{'results'};

    if ($next) {
        my ( $next_code, $next_content ) = _get_page($next);
        my $next_arrayref = $next_content->{'results'};
        foreach my $t (@$next_arrayref) {
            push( @$result_arrayref, $t );
        }
        return ( $code, $content );
    }
    else {
        return ( $code, $content );
    }
}

#check parameters are all valid
sub _check {
    my $self   = shift;
    my $config = $self->{'_config'};
    if ( !exists $config->{host} ) {
        $self->{'_error'} .= "Invalid host;";
    }
    if ( !exists $config->{api_version} ) {
        $self->{'_error'} .= "Invalid api_version;";
    }
    if ( !exists $config->{resource} ) {
        $self->{'_error'} .= "Invalid resource name;";
    }
    return 0 if ( exists $self->{'_error'} );
    return 1;
}

sub _buildAccessors {
    my $self = shift;

    return if $self->can('setHost');

    my @attributes = qw(Host Api_version Resource Search Unique);

    for my $attribute (@attributes) {
        my $set_method = "
        sub {
        my \$self = shift;
        \$self->{'_config'}{lc('$attribute')} = shift;
        return \$self->{'_config'}{lc('$attribute')};
        }";

        my $get_method = "
        sub {
        my \$self = shift;
        return \$self->{'_config'}{lc('$attribute')};
        }";

        {
            no strict 'refs';
            *{ 'PDC::RestClient::set' . $attribute } = eval $set_method;
            *{ 'PDC::RestClient::get' . $attribute } = eval $get_method;
        }

    }

    return;
}

=head2 new

Create an Rest::Client object to communicate with PDC server

=cut

sub new {
    my $class = shift;
    my $config;

    $class->_buildAccessors();

    if ( ref $_[0] eq 'HASH' ) {
        $config = shift;
    }
    elsif ( scalar @_ && scalar @_ % 2 == 0 ) {
        $config = {@_};
    }
    else {
        $config = {};
    }

    my $self = bless( {}, $class );

    #hardcode server and rest api version here.
    $config->{'host'}        = "https://pdc.engineering.redhat.com/";
    $config->{'api_version'} = "v1";

    $self->{'_config'} = $config;

    return $self;
}

=head1 AUTHOR

Yang,Ren, C<< <ryang at redhat.com> >>

=head1 BUGS

For any issue please email ryang@redhat.com

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PDC::RestClient

You can also look for information at docs folder in source code.

=head1 COPYRIGHT & LICENSE

Copyright 2017 Yang,Ren.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    #End of PDC::RestClient
