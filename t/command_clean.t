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

is $nodebrew->run('clean', ['v0.1.1']), "Cleaned v0.1.1\n";
ok !-e "$nodebrew->{src_dir}/v0.1.1";
ok -e "$nodebrew->{src_dir}/v0.1.2";
ok -e "$nodebrew->{src_dir}/v0.6.0";
ok -e "$nodebrew->{src_dir}/v0.6.1";

is $nodebrew->run('clean', ['0.6.0']), "Cleaned v0.6.0\n"; # without 'v'
ok !-e "$nodebrew->{src_dir}/v0.6.0";

is $nodebrew->run('clean', ['all']), "Cleaned all\n";
ok !-e "$nodebrew->{src_dir}/v0.1.2";
ok !-e "$nodebrew->{src_dir}/v0.6.1";

is $nodebrew->run('clean', []), "version is required\n";

done_testing;
