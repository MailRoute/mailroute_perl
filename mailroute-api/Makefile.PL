use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'MailrouteAPI',
    AUTHOR           => q{<devrow@gmail.com>},
    VERSION_FROM     => 'lib/MailrouteAPI.pm',
    ABSTRACT_FROM    => 'lib/MailrouteAPI.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        JSON => 0,
        'HTTP::Response' => 0,
        'WWW::Curl::Easy' => 0,
        'Data::Dumper' => 0,
        'Digest::MD5' => 0,
        Carp => 0
    },
    depend => {
        'BaseAPI.pm' => 'lib/MailrouteAPI/BaseAPI.pm'
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'MailrouteAPI-*' },
    test => { TESTS => 't/MailrouteAPI/*.t' },
);
