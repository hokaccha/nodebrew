use strict;
use warnings;

use t::Util;
use Test::More;
use File::Read;

my $nodebrew = init_nodebrew();

my $new_source = 'nodebrew updated source';
open my $fh, '>', "$data_dir/nodebrew";
print $fh $new_source;
$nodebrew->run('selfupdate');
is read_file("$nodebrew->{brew_dir}/nodebrew"), $new_source;

done_testing;
