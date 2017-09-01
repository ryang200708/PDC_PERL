use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'PDC',
    AUTHOR              => q{Yang,Ren <ryang@redhat.com>},
    VERSION_FROM        => 'lib/PDC.pm',
    ABSTRACT_FROM       => 'lib/PDC.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 1,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PDC-*' },
);
