use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');

ok !-e "$nodebrew->{node_dir}/v0.1.1";
ok !-e "$nodebrew->{src_dir}/v0.1.1";
ok !-e "$nodebrew->{src_dir}/v0.1.1/node-v0.1.1.tar.gz";
ok !-e "$nodebrew->{src_dir}/v0.1.1/node-v0.1.1";
unlike $nodebrew->run('list'), qr/v0.1.1/;
like $nodebrew->run('list'), qr/not installed/;

$nodebrew->run('install', ['v0.1.1']);
ok -e "$nodebrew->{node_dir}/v0.1.1";
ok -e "$nodebrew->{src_dir}/v0.1.1";
ok -e "$nodebrew->{src_dir}/v0.1.1/node-v0.1.1.tar.gz";
ok -e "$nodebrew->{src_dir}/v0.1.1/node-v0.1.1";
like $nodebrew->run('list'), qr/v0.1.1/;
like $nodebrew->run('list'), qr/current: none/;
is $nodebrew->run('install', ['v0.1.1']), "v0.1.1 is already installed\n";
is $nodebrew->run('install', ['0.1.1']), "v0.1.1 is already installed\n";
like $nodebrew->run('install', ['v0.1.3']), qr/v0.1.3 is not found/;
like $nodebrew->run('install', ['0.1.3']), qr/v0.1.3 is not found/;

$nodebrew->run('install', ['v0.1.x']);
like $nodebrew->run('list'), qr/v0.1.2/;

$nodebrew->run('install', ['0.6.0']);
like $nodebrew->run('list'), qr/v0.6.0/;

$nodebrew->run('install', ['latest']);
like $nodebrew->run('list'), qr/v0.6.1/;

is $nodebrew->run('install', []), "version is required\n";

done_testing;
