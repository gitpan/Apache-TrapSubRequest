use strict;
use warnings;
use ExtUtils::MakeMaker;

BEGIN {
    eval { use Apache2 };
}

use Apache::TestMM  qw(test clean);

Apache::TestMM::filter_args();
Apache::TestMM::generate_script('t/TEST');

WriteMakefile(
    NAME                => 'Apache::TrapSubRequest',
    AUTHOR              => 'dorian taylor <dorian@cpan.org>',
    VERSION_FROM        => 'lib/Apache/TrapSubRequest.pm',
    ABSTRACT_FROM       => 'lib/Apache/TrapSubRequest.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Apache-TrapSubRequest-* t/TEST' },
);
