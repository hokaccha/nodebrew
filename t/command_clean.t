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

is $nodebrew->run('clean', ['v6.2.0']), "Cleaned v6.2.0\n";
ok !-e "$nodebrew->{src_dir}/v6.2.0";
ok -e "$nodebrew->{src_dir}/v6.2.1";
ok -e "$nodebrew->{src_dir}/v8.9.0";
ok -e "$nodebrew->{src_dir}/v8.9.4";

is $nodebrew->run('clean', ['6.2.1']), "Cleaned v6.2.1\n"; # without 'v'
ok !-e "$nodebrew->{src_dir}/v6.2.1";

is $nodebrew->run('clean', ['all']), "Cleaned all\n";
ok !-e "$nodebrew->{src_dir}/v8.9.0";
ok !-e "$nodebrew->{src_dir}/v8.9.4";

is $nodebrew->run('clean', []), "version is required\n";

done_testing;
