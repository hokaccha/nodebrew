use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');

$nodebrew->run('install-binary', ['io@next-nightly']);
ok -e "$nodebrew->{iojs_dir}/v3.0.0-next-nightly20150717cbec3ee19d";
ok -e "$nodebrew->{iojs_dir}/v3.0.0-next-nightly20150717cbec3ee19d/binary";
ok -e "$nodebrew->{src_dir}/v3.0.0-next-nightly20150717cbec3ee19d/iojs-v3.0.0-next-nightly20150717cbec3ee19d-linux-x86.tar.gz";
like $nodebrew->run('list'), qr/next-nightly/;

done_testing;
