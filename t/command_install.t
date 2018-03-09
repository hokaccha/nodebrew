use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');

$nodebrew->run('install', ['v8.9.0']);
ok -e "$nodebrew->{node_dir}/v8.9.0";
ok -e "$nodebrew->{node_dir}/v8.9.0/binary";
ok -e "$nodebrew->{src_dir}/v8.9.0/node-v8.9.0-linux-x86.tar.gz";
like $nodebrew->run('list'), qr/v8.9.0/;
is $nodebrew->run('install', ['v8.9.0']), "v8.9.0 is already installed\n";
like $nodebrew->run('install', ['v8.9.1']), qr/v8.9.1 is not found/;

done_testing;
