use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');
$nodebrew->run('install', ['v8.9.0']);
$nodebrew->run('install', ['v8.9.4']);
$nodebrew->run('use', ['v8.9.4']);

# ls
is $nodebrew->run('list'), $nodebrew->run('ls');
like $nodebrew->run('list'), qr/current: v8.9.4/;

# ls-remote
like $nodebrew->run('ls-remote'), qr/v0.1.1    v0.1.2/;

# ls-all
like $nodebrew->run('ls-all'), qr/remote:/;
like $nodebrew->run('ls-all'), qr/local:/;
like $nodebrew->run('ls-all'), qr/current: v8.9.4/;

done_testing;
