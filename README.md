# DBIx::Class::Storage::DBI::MariaDB

Storage::DBI class implementing MariaDB specifics

## Description

This module adds support for MariaDB in the DBIx::Class ORM. It supports
exactly the same parameters as the [DBIx::Class::Storage::DBI::mysql](https://metacpan.org/pod/DBIx::Class::Storage::DBI::mysql)
module, so check that for further documentation.

## Installation

```
$ cpanm DBIx::Class::Storage::DBI::MariaDB
```

## Usage

Similar to other storage modules that are builtin to DBIx::Class, all you need
to do is ensure `DBIx::Class::Storage::DBI::MariaDB` is loaded and specify 
MariaDB in the DSN. For example:

```perl
package MyApp::Schema;
use base 'DBIx::Class::Schema';

# register classes
# ...
# load mariadb storage
__PACKAGE__->ensure_class_loaded('DBIx::Class::Storage::DBI::MariaDB');

package MyApp;
use MyApp::Schema;

my $dsn = "dbi:MariaDB:database=mydb";
my $user = "noone";
my $pass = "topsecret";
my $schema = MyApp::Schema->connect($dsn, $user, $pass);
```

## Copyright and License

Copyright (C) 2023 Siemplexus

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.