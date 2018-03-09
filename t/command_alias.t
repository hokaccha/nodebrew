use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');
$nodebrew->run('install', ['v8.9.0']);
$nodebrew->run('install', ['v8.9.4']);

ok !-e "$nodebrew->{alias_file}";
is $nodebrew->run('alias', ['foo', 'bar']), "foo -> bar\n";
ok -e "$nodebrew->{alias_file}";
is $nodebrew->run('alias'), "foo -> bar\n";

is $nodebrew->run('alias', ['hoge', 'fuga']), "hoge -> fuga\n";
like $nodebrew->run('alias'), qr/foo -> bar\n/;
like $nodebrew->run('alias'), qr/hoge -> fuga\n/;

is $nodebrew->run('alias', ['foo', 'baz']), "foo -> baz\n";
like $nodebrew->run('alias'), qr/foo -> baz\n/;
like $nodebrew->run('alias'), qr/hoge -> fuga\n/;

is $nodebrew->run('alias', ['baz']), "baz is not set alias\n";
is $nodebrew->run('alias', ['foo']), "foo -> baz\n";

$nodebrew->run('alias', ['foo', 'v8.9.0']);
$nodebrew->run('use', ['foo']);
like $nodebrew->run('list'), qr/current: v8.9.0/;

$nodebrew->run('alias', ['8.9', '8.9.x']);
$nodebrew->run('use', ['8.9']);
like $nodebrew->run('list'), qr/current: v8.9.4/;

is $nodebrew->run('unalias', ['foo']), "Removed foo\n";
like $nodebrew->run('alias'), qr/8.9 -> 8.9.x\n/;
like $nodebrew->run('alias'), qr/hoge -> fuga\n/;

is $nodebrew->run('unalias', ['foo']), "foo is not defined\n";

done_testing;
