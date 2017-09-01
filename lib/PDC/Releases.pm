package PDC::Releases;

use warnings;
use strict;
use PDC::Release;
use PDC::ReleaseType;
use PDC::RestClient;

=head1 NAME

PDC::Releases

=head1 SYNOPSIS

    use PDC::Releases;

Method: GET

URL: /rest_api/v1/releases/

Query params:

    active (bool)
    base_product (string)
    brew_allowed_tag (string)
    brew_default_target (string | null)
    bugzilla_product (string | null)
    dist_git_branch (string | null)
    errata_product_version (string | null)
    has_base_product (string)
    integrated_with (string | null)
    name (string)
    product_pages_release_id (int)
    product_version (string)
    release_id (string)
    release_type (string)
    short (string)
    version (string)
    ordering is used to override the ordering of the results, the value could be: ['release_id', 'name', 'product_version', 'short', 'integrated_with', 'version', 'active', 'base_product', 'release_type'] .

Response: a paged list of following objects

{
    "active (optional, default=true)": "boolean", 
    "base_product (optional, default=null, nullable)": "BaseProduct.base_product_id", 
    "brew (optional, default=null, nullable)": {
        "allowed_tags (optional, default=null)": [
            "string"
        ], 
        "default_target (optional, default=null, nullable)": "string"
    }, 
    "bugzilla (optional, default=null, nullable)": {
        "product (optional, default=null)": "string"
    }, 
    "compose_set (read-only)": "[Compose.compose_id]", 
    "dist_git (optional, default=null, nullable)": {
        "branch (optional, default=null)": "string"
    }, 
    "errata (optional, default=null, nullable)": {
        "product_version (optional, default=null, nullable)": "string"
    }, 
    "integrated_with (optional, default=null, nullable)": "Release.release_id", 
    "name": "string", 
    "product_pages (optional, default=null, nullable)": {
        "release_id": "int"
    }, 
    "product_version (optional, default=null, nullable)": "ProductVersion.product_version_id", 
    "release_id (read-only)": "string", 
    "release_type": "ReleaseType.short", 
    "short": "string", 
    "version": "string"
}

=head1 FUNCTIONS

=cut

sub refresh {
    my $self = shift;
    $self->_clean;
    my $rest_client = PDC::RestClient->new( { resource => 'releases' } );
    my $result = $rest_client->list( $self->getSearch );
    if ( $result->{'code'} == 200 ) {
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
            *{ 'PDC::Releases::set' . $attribute } = eval $set_method;
            *{ 'PDC::Releases::get' . $attribute } = eval $get_method;
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

1;    #End of PDC::Release
