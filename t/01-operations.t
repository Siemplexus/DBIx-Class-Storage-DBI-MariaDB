use strict;
use warnings;

use Test::More;
use Test::Exception;

use lib qw(t/lib);
use MyApp::Schema;

my ( $dsn, $user, $pass ) =
  @ENV{ map { "DBICTEST_MARIADB_${_}" } qw/DSN USER PASS/ };

plan skip_all => 'Set $ENV{DBICTEST_MARIADB_DSN}, _USER and _PASS to run tests'
  unless ( $dsn && $user );

my $schema = MyApp::Schema->connect( $dsn, $user, $pass );

my $dbh = $schema->storage->dbh;

# initialize tables
$dbh->do("DROP TABLE IF EXISTS author");
$dbh->do(
    "CREATE TABLE author (
    artistid INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    name VARCHAR(100),
    rank INTEGER NOT NULL DEFAULT 13,
    charfield CHAR(10)
)"
);
$dbh->do("DROP TABLE IF EXISTS owner");
$dbh->do(
    "CREATE TABLE owner (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
)"
);
$dbh->do("DROP TABLE IF EXISTS book");
$dbh->do(
    "CREATE TABLE book (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    source VARCHAR(100) NOT NULL,
    owner INTEGER NOT NULL,
    title VARCHAR(100) NOT NULL,
    price INTEGER
)"
);

subtest 'sqlt_type overrides' => sub {
    my $schema = MyApp::Schema->connect( $dsn, $user, $pass );
    ok( !$schema->storage->_dbh, 'definitely not connected' );
    is( $schema->storage->sqlt_type,
        'MySQL', 'sqlt_type correct pre-connection' );
};

subtest 'primary key handling' => sub {
    my $new =
      $schema->resultset('Artist')->create( { name => 'Duke Ellington' } );
    ok( $new->artistid, 'Auto-PK worked' );
};

subtest 'LIMIT support' => sub {
    for ( 1 .. 6 ) {
        $schema->resultset('Artist')->create( { name => 'Artist ' . $_ } );
    }
    my $it = $schema->resultset('Artist')
      ->search( {}, { rows => 3, offset => 2, order_by => 'artistid' } );
    is( $it->count,      3,          'LIMIT count ok' );
    is( $it->next->name, 'Artist 2', 'iterator->next ok' );
    $it->next;
    $it->next;
    is( $it->next, undef, 'next past end of resultset ok' );
};

subtest 'LIMIT with select-lock' => sub {
    lives_ok {
        $schema->txn_do(
            sub {
                isa_ok(
                    $schema->resultset('Artist')->find(
                        { artistid => 1 },
                        { for      => 'update', rows => 1 }
                    ),
                    'MyApp::Schema::Artist'
                );
            }
        );
    }
    'Limited FOR UPDATE select works';
};

subtest 'LIMIT with shared lock' => sub {
    lives_ok {
        $schema->txn_do(
            sub {
                isa_ok(
                    $schema->resultset('Artist')
                      ->find( { artistid => 1 }, { for => 'shared' } ),
                    'MyApp::Schema::Artist'
                );
            }
        );
    }
    'LOCK IN SHARE MODE select works';
};

$schema->populate( 'Owner', [ 
    [qw/id name/], 
    [qw/1  wiggle/], 
    [qw/2  woggle/], 
    [qw/3  boggle/], 
] );
$schema->populate(
    'BooksInLibrary',
    [
        [qw/source  owner title   /], 
        [qw/Library 1     secrets1/],
        [qw/Eatery  1     secrets2/], 
        [qw/Library 2     secrets3/],
    ]
);

subtest 'distinct + prefetch on tables with identically named columns' => sub {

    # try ->has_many
    my $owners = $schema->resultset('Owner')->search(
        { 'books.id' => { '!=', undef } },
        { prefetch   => 'books', distinct => 1 }
    );
    my $owners2 = $schema->resultset('Owner')
      ->search( { id => { -in => $owners->get_column('me.id')->as_query } } );
    for ( $owners, $owners2 ) {
        is( $_->all, 2,
            'Prefetched grouped search returns correct number of rows' );
        is( $_->count, 2, 'Prefetched grouped search returns correct count' );
    }

    #try ->belongs_to
    my $books =
      $schema->resultset('BooksInLibrary')
      ->search( { 'owner.name' => 'wiggle' },
        { prefetch => 'owner', distinct => 1 } );
    my $books2 = $schema->resultset('BooksInLibrary')
      ->search( { id => { -in => $books->get_column('me.id')->as_query } } );
    for ( $books, $books2 ) {
        is( $_->all, 1,
            'Prefetched grouped search returns correct number of rows' );
        is( $_->count, 1, 'Prefetched grouped search returns correct count' );
    }
};

done_testing();
