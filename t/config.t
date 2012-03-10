use strict;
use warnings;
use Test::More;
use FindBin;
use File::Read;

require 'nodebrew';

is_deeply Nodebrew::Config::_parse('
foo = bar=baz
hoge = fuga = piyo
'), { foo => 'bar=baz', hoge => 'fuga = piyo' };

is_deeply Nodebrew::Config::_parse('
foo = bar
hoge=fuga
'), { foo => 'bar', hoge => 'fuga' };

is Nodebrew::Config::_strigify({
    foo => 'bar',
    hoge => 'fuga',
}), "foo = bar\nhoge = fuga\n";

my $config_file = "$FindBin::Bin/_config";
my $config = Nodebrew::Config->new($config_file);

ok !-e $config_file;
is_deeply $config->get_all(), {};
is $config->get('foo'), undef;
is $config->set('foo', 'bar'), 1;
is $config->get('foo'), 'bar';
is_deeply $config->get_all(), { foo => 'bar' };
is $config->save(), 1;
ok -e $config_file;
is read_file($config_file), "foo = bar\n";

unlink $config_file;

done_testing;
