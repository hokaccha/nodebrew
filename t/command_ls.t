use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');
$nodebrew->run('install', ['v0.6.0']);
$nodebrew->run('install', ['v0.6.1']);
$nodebrew->run('use', ['v0.6.1']);

# ls
is $nodebrew->run('list'), $nodebrew->run('ls');
like $nodebrew->run('list'), qr/current: v0.6.1/;

# ls-remote
like $nodebrew->run('ls-remote'), qr/v0.1.1    v0.1.2/;

# ls-all
like $nodebrew->run('ls-all'), qr/remote:/;
like $nodebrew->run('ls-all'), qr/local:/;
like $nodebrew->run('ls-all'), qr/current: v0.6.1/;

done_testing;
