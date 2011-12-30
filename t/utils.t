use strict;
use warnings;
use Test::More;

require 'nodebrew';

is_deeply Nodebrew::Utils::sort_version([
    'v0.5.0',
    'v0.10.0',
    'v0.0.1',
    'v0.0.2',
    'v0.1.0',
    'v0.1.1',
    'v0.1.2',
    'v0.1.10',
    'v1.0.0',
    'v2.0.0',
    'v10.0.0',
]), [
    'v0.0.1',
    'v0.0.2',
    'v0.1.0',
    'v0.1.1',
    'v0.1.2',
    'v0.1.10',
    'v0.5.0',
    'v0.10.0',
    'v1.0.0',
    'v2.0.0',
    'v10.0.0',
];

done_testing;
