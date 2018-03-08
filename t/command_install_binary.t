use strict;
use warnings;

use t::Util;
use Test::More;

{
    no warnings;
    *Nodebrew::Utils::system_info = sub {
        return ('linux', 'x86');
    };
}

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');

$nodebrew->run('install-binary', ['v0.4.0']);
ok -e "$nodebrew->{node_dir}/v0.4.0";
ok -e "$nodebrew->{node_dir}/v0.4.0/binary";
ok -e "$nodebrew->{src_dir}/v0.4.0/node-v0.4.0-linux-x86.tar.gz";
like $nodebrew->run('list'), qr/v0.4.0/;
is $nodebrew->run('install-binary', ['v0.4.0']), "v0.4.0 is already installed\n";
like $nodebrew->run('install-binary', ['v0.4.1']), qr/v0.4.1 is not found/;

$nodebrew->run('install-binary', ['io@1.0.0']);
ok -e "$nodebrew->{iojs_dir}/v1.0.0";
ok -e "$nodebrew->{iojs_dir}/v1.0.0/binary";
ok -e "$nodebrew->{src_dir}/v1.0.0/iojs-v1.0.0-linux-x86.tar.gz";
like $nodebrew->run('list'), qr/io\@v1.0.0/;

done_testing;
