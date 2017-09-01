package PDC::Release;

use warnings;
use strict;
use PDC::ReleaseType;
use PDC::RestClient;
use PDC::Util;

=head1 NAME

PDC::Release

=head1 SYNOPSIS

    use PDC::Release;

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
    my $result = $rest_client->retrieve( $self->getRelease_id );
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
        delete $self->{$key} if ( $key ne 'release_id' );
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

    return if $self->can('setRelease_id');

    my @attributes = qw(Release_id);

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
            *{ 'PDC::Release::set' . $attribute } = eval $set_method;
            *{ 'PDC::Release::get' . $attribute } = eval $get_method;
        }

    }
    return;
}

=head2 new

create instance

=cut

sub new {
    my $class = shift;
    my ($release_id) = (@_) if (@_);
    $class->_buildAccessors();

    if ( defined $release_id and !ref($release_id) and $release_id ) {
        my $self = bless( {}, $class );
        $self->setRelease_id($release_id);
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

1;    #End of PDC::Release
