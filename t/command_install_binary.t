use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');

$nodebrew->run('install', ['v8.9.0']);
ok -e "$nodebrew->{node_dir}/v8.9.0";

done_testing;
