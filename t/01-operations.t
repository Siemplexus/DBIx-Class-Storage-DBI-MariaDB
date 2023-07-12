use strict;
use warnings;
use Test::More;
use lib qw(t/lib);
use MyApp::Schema;

my ( $dsn, $user, $pass ) =
  @ENV{ map { "DBICTEST_MARIADB_${_}" } qw/DSN USER PASS/ };

plan skip_all => 'Set $ENV{DBICTEST_MARIADB_DSN}, _USER and _PASS to run tests'
  unless ( $dsn && $user );

my $schema = MyApp::Schema->connect( $dsn, $user, $pass );

my $dbh = $schema->storage->dbh;

# initialize tables
$dbh->do("DROP TABLE IF EXISTS author;");
$dbh->do(
"CREATE TABLE author (id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255))"
);

subtest 'sqlt_type overrides' => sub {
    my $schema = MyApp::Schema->connect( $dsn, $user, $pass );
    ok( !$schema->storage->_dbh, 'definitely not connected' );
    is( $schema->storage->sqlt_type,
        'MySQL', 'sqlt_type correct pre-connection' );
};

subtest 'primary key handling' => sub {
    my $new =
      $schema->resultset('Author')->create( { name => 'Albert Camus' } );
    ok( $new->id, 'Auto-PK worked' );
};

subtest 'LIMIT support' => sub {
    for ( 1 .. 6 ) {
        $schema->resultset('Author')->create( { name => 'Artist ' . $_ } );
    }
    my $it = $schema->resultset('Author')
      ->search( {}, { rows => 3, offset => 2, order_by => 'id' } );
    is( $it->count,      3,          'LIMIT count ok' );
    is( $it->next->name, 'Artist 2', 'iterator->next ok' );
    $it->next;
    $it->next;
    is( $it->next, undef, 'next past end of resultset ok' );
};

done_testing();
