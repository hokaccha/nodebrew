use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');
$nodebrew->run('install', ['v0.6.0']);
$nodebrew->run('install', ['v0.6.1']);
$nodebrew->run('use', ['v0.6.1']);

is $nodebrew->run('uninstall', ['v0.6.1']), "v0.6.1 uninstalled\n";
ok !-e "$nodebrew->{node_dir}/v0.6.1";
unlike $nodebrew->run('list'), qr/v0.6.1/;
like $nodebrew->run('list'), qr/current: none/;
is readlink "$nodebrew->{current}", "$nodebrew->{default_dir}";

is $nodebrew->run('uninstall', ['v0.6.1']), "v0.6.1 is not installed\n";
is $nodebrew->run('uninstall', ['foo']), "foo is not installed\n";
is $nodebrew->run('uninstall', ['0.6.0']), "v0.6.0 uninstalled\n"; # without v
ok !-e "$nodebrew->{node_dir}/v0.6.0";

is $nodebrew->run('uninstall', []), "version is required\n";

done_testing;
