use strict;
use warnings;
use Test::More;
use lib qw(t/lib);
use MyApp::Schema;

my ($dsn, $user, $pass) = @ENV{map { "DBICTEST_MARIADB_${_}" } qw/DSN USER PASS/};

plan skip_all => 'Set $ENV{DBICTEST_MARIADB_DSN}, _USER and _PASS to run tests'
    unless ($dsn && $user);

my $schema = MyApp::Schema->connect($dsn, $user, $pass);

subtest 'load storage' => sub {
    ok 1;
};

done_testing();