use strict;
use warnings;

use t::Util;
use Test::More;
use File::Read;

my $nodebrew = init_nodebrew();

ok !-e "$nodebrew->{brew_dir}/nodebrew";
ok !-e "$nodebrew->{src_dir}";
ok !-e "$nodebrew->{node_dir}";
ok !-e "$nodebrew->{iojs_dir}";
ok !-e "$nodebrew->{default_dir}";
ok !-e "$nodebrew->{current}";

like $nodebrew->run('setup'), qr/Installed nodebrew/;

is read_file("$nodebrew->{brew_dir}/nodebrew"), 'nodebrew source';
ok -e "$nodebrew->{src_dir}";
ok -e "$nodebrew->{node_dir}";
ok -e "$nodebrew->{iojs_dir}";
ok -e "$nodebrew->{default_dir}";
is readlink "$nodebrew->{current}", "$nodebrew->{default_dir}";

done_testing;
