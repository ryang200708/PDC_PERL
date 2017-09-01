package PDC::ReleaseVariantType;

use warnings;
use strict;
use PDC::Util;
use PDC::RestClient;
use Data::Dumper;

=head1 NAME

PDC::ReleaseType 

=head1 SYNOPSIS

    Method: GET

    URL: /rest_api/v1/release-types/

    Query params:

        name (string, case insensitive, substring match)
        short (string)
        ordering is used to override the ordering of the results, the value could be: ['short', 'name', 'suffix'] .

    Response: a paged list of following objects

    {
        "name": "string", 
        "short": "string", 
        "suffix": "string"
    }

=head1 FUNCTIONS

=head2 update

    TODO
    only can run this method in object confimed unique and existed in server(by method ->check).
    update object in server with current data in object

=cut 

sub update {
    my $class = shift;
    return 0;

    #    return 1;
}

=head2 delete

    TODO
    delete object in server

=cut

sub delete {
    my $class = shift;
    return 0;

    #    return 1;
}

=head2 get_all_base_product
    
    TODO
    get all base product object belong to current ReleaseType

=cut

sub get_all_base_product {

}

=head2 get_history

    TODO
    get log for this object

=cut

sub get_history {
    my $class = shift;
    return 0;
}

=head2 get_latest_history

    TODO
    get latest log for this object

=cut

sub get_latest_history {
    my $class = shift;
    return 0;
}

sub _check_name {
    return 1;
}

sub _check_short {
    return 1;
}

sub _check_suffix {
    return 1;
}

=head2 init_with_short

    As short is the unique of ReleaseType.
    Init the object by seaching server with the short name;
    Same as init_with_search("short=ga")

=cut

sub init_with_short {
    my $self = shift;
    if ( !exists( $self->{'short'} ) ) {
        print "'short' is required\n";
        return 0;
    }
    return $self->init_with_search( "short=" . $self->{'short'} );
}

=head2 init_with_search

    Init the object by seaching server with all given parameters. 
    Init successed if return with one unique record with all given parameters.

=cut

sub init_with_search {
    my $self     = shift;
    my ($search) = @_;
    my $t        = search( ( 'release-types', $search ) );
    if ($t) {
        return $self->_init_s1($t);
    }
    else {
        return 0;
    }
}

#get data from server to real create local object. For now we only allow use 'short' to create new ReleaseType object.
sub _init_s2 {
    my $self   = shift;
    my $search = '';
    $search .= "short=" . $self->{'short'} if ( exists( $self->{'short'} ) );
    $search .= "&name=" . $self->{'name'}  if ( exists( $self->{'name'} ) );
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
                    $self->{"$pair[0]"} = $pair[1]
                      if ( _check_name( $pair[1] ) );
                }
                elsif ( $pair[0] eq "short" ) {
                    $self->{"$pair[0]"} = $pair[1]
                      if ( _check_short( $pair[1] ) );
                }
                elsif ( $pair[0] eq "suffix" ) {
                    $self->{"$pair[0]"} = $pair[1]
                      if ( _check_suffix( $pair[1] ) );
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

1;    #End of PDC::ReleaseVariantType
