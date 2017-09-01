#!/usr/bin/perl

BEGIN {
}

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
    use_ok('PDC');
    use_ok('PDC::BaseProduct');
}

diag("Testing PDC $PDC::VERSION, Perl $], $^X");
