use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();

like $nodebrew->run('help'), qr/Usage:/;
is $nodebrew->run(), $nodebrew->run('help');
is $nodebrew->run('invalid command'), $nodebrew->run('help');

done_testing;
