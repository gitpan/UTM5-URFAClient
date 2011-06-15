use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'UTM5::URFAClient',
    AUTHOR              => q{Nikita Melikhov <ver@0xff.su>},
    VERSION_FROM        => 'lib/UTM5/URFAClient.pm',
    ABSTRACT_FROM       => 'lib/UTM5/URFAClient.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'UTM5-URFAClient-*' },
);
