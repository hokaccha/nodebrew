use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');
$nodebrew->run('install', ['v0.1.1']);
$nodebrew->run('install', ['v0.1.2']);
$nodebrew->run('install', ['v0.6.0']);
$nodebrew->run('install', ['v0.6.1']);

$nodebrew->run('use', ['v0.1.1']);
like $nodebrew->run('list'), qr/current: v0.1.1/;
is readlink "$nodebrew->{current}", "$nodebrew->{node_dir}/v0.1.1";

$nodebrew->run('use', ['v0.1.x']);
like $nodebrew->run('list'), qr/current: v0.1.2/;

$nodebrew->run('use', ['0.6.0']); # without 'v'
like $nodebrew->run('list'), qr/current: v0.6.0/;

$nodebrew->run('use', ['0.1.x']); # without 'v'
like $nodebrew->run('list'), qr/current: v0.1.2/;

$nodebrew->run('use', ['0.1.1']); # without 'v'
$nodebrew->run('use', ['0.1']); # without 'v'
like $nodebrew->run('list'), qr/current: v0.1.2/;

$nodebrew->run('use', ['latest']);
like $nodebrew->run('list'), qr/current: v0.6.1/;

is $nodebrew->run('use', ['v0.3.0']), "v0.3.0 is not installed\n";
is $nodebrew->run('use', ['0.3.0']), "v0.3.0 is not installed\n";
is $nodebrew->run('use', ['foo']), "foo is not installed\n";
like $nodebrew->run('list'), qr/current: v0.6.1/;

is $nodebrew->run('use', []), "version is required\n";

done_testing;
