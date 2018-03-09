use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');

ok !-e "$nodebrew->{node_dir}/v8.9.0";
ok !-e "$nodebrew->{src_dir}/v8.9.0";
ok !-e "$nodebrew->{src_dir}/v8.9.0/node-v8.9.0.tar.gz";
ok !-e "$nodebrew->{src_dir}/v8.9.0/node-v8.9.0";
unlike $nodebrew->run('list'), qr/v8.9.0/;
like $nodebrew->run('list'), qr/not installed/;

$nodebrew->run('compile', ['v8.9.0']);
ok -e "$nodebrew->{node_dir}/v8.9.0";
ok -e "$nodebrew->{src_dir}/v8.9.0";
ok -e "$nodebrew->{src_dir}/v8.9.0/node-v8.9.0.tar.gz";
ok -e "$nodebrew->{src_dir}/v8.9.0/node-v8.9.0";
like $nodebrew->run('list'), qr/v8.9.0/;
like $nodebrew->run('list'), qr/current: none/;
is $nodebrew->run('compile', ['v8.9.0']), "v8.9.0 is already installed\n";
like $nodebrew->run('compile', ['v8.9.5']), qr/v8.9.5 is not found/;

is $nodebrew->run('compile', []), "version is required\n";

done_testing;
