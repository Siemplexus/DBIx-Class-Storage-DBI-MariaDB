package MyApp::Schema::Author;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('author');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INTEGER',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    name => {
        data_type   => 'VARCHAR',
        size        => 255,
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['name']);

package MyApp::Schema::Book;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('book');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INTEGER',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    title => {
        data_type   => 'TEXT',
        is_nullable => 0,
    },
);

package MyApp::Schema;

use strict;
use warnings;
use base 'DBIx::Class::Schema';

__PACKAGE__->register_class( 'Author', 'MyApp::Schema::Author' );
__PACKAGE__->ensure_class_loaded('DBIx::Class::Storage::DBI::MariaDB');
__PACKAGE__->ensure_class_loaded('DBIx::Class::Storage::DBI');

# __PACKAGE__->inject_base('DBIx::Class::Storage::DBI', 'DBIx::Class::Storage::DBI::MariaDB');

1;
