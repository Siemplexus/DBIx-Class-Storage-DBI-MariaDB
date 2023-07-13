use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => "DBIx::Class::Storage::DBI::MariaDB",
    VERSION_FROM    => "lib/DBIx/Class/Storage/DBI/MariaDB.pm",
    PREREQ_PM       => {
        'Test::More'        => 0,
        'Test::Warn'        => 0,
        'Test::Exception'   => 0,
        'DBD::MariaDB'      => '1.22',
        'DBIx::Class'       => '>= 0.082840',
    },
)