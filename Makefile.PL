use 5.008009;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Plack::Middleware::Rewrite',
    VERSION_FROM => 'lib/Plack/Middleware/Rewrite.pm',    # finds $VERSION
    PREREQ_PM    => {
        q{Plack::Middleware} => 0,
        q{Plack::Response}   => 0,
        q{Plack::Reply}      => 0,
        q{Exporter}
    },
    (   $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
            (
            ABSTRACT_FROM => 'lib/Plack/Middleware/Rewrite.pm'
            ,    # retrieve abstract from module
            AUTHOR => 'scook <scook@nonet>'
            )
        : ()
    ),
);
