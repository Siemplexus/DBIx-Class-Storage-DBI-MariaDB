package MyApp::Schema::Table;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('table');
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

package MyApp::Schema;

use strict;
use warnings;
use base 'DBIx::Class::Schema';

__PACKAGE__->register_class('Table', 'MyApp::Schema::Table');
__PACKAGE__->ensure_class_loaded('DBIx::Class::Storage::DBI::MariaDB');
__PACKAGE__->ensure_class_loaded('DBIx::Class::Storage::DBI');
# __PACKAGE__->inject_base('DBIx::Class::Storage::DBI', 'DBIx::Class::Storage::DBI::MariaDB');

1;