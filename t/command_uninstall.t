use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');
$nodebrew->run('install', ['v8.9.0']);
$nodebrew->run('install', ['v8.9.4']);
$nodebrew->run('use', ['v8.9.4']);

is $nodebrew->run('uninstall', ['v8.9.4']), "v8.9.4 uninstalled\n";
ok !-e "$nodebrew->{node_dir}/v8.9.4";
unlike $nodebrew->run('list'), qr/v8.9.4/;
like $nodebrew->run('list'), qr/current: none/;
is readlink "$nodebrew->{current}", "$nodebrew->{default_dir}";

is $nodebrew->run('uninstall', ['v8.9.4']), "v8.9.4 is not installed\n";
is $nodebrew->run('uninstall', ['foo']), "foo is not installed\n";
is $nodebrew->run('uninstall', ['8.9.0']), "v8.9.0 uninstalled\n"; # without v
ok !-e "$nodebrew->{node_dir}/v8.9.0";

is $nodebrew->run('uninstall', []), "version is required\n";

done_testing;
