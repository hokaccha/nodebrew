use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');
$nodebrew->run('install', ['v6.2.0']);
$nodebrew->run('install', ['v6.2.1']);
$nodebrew->run('install', ['v8.9.0']);
$nodebrew->run('install', ['v8.9.4']);

$nodebrew->run('use', ['v6.2.0']);
like $nodebrew->run('list'), qr/current: v6.2.0/;
is readlink "$nodebrew->{current}", "$nodebrew->{node_dir}/v6.2.0";

$nodebrew->run('use', ['v6.2.x']);
like $nodebrew->run('list'), qr/current: v6.2.1/;

$nodebrew->run('use', ['6.2.0']); # without 'v'
like $nodebrew->run('list'), qr/current: v6.2.0/;

$nodebrew->run('use', ['latest']);
like $nodebrew->run('list'), qr/current: v8.9.4/;

is $nodebrew->run('use', ['v0.3.0']), "v0.3.0 is not installed\n";
is $nodebrew->run('use', ['0.3.0']), "v0.3.0 is not installed\n";
is $nodebrew->run('use', ['foo']), "foo is not installed\n";
like $nodebrew->run('list'), qr/current: v8.9.4/;

is $nodebrew->run('use', []), "version is required\n";

done_testing;
