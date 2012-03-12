use strict;
use warnings;
use Test::More;
use FindBin;
use Test::TCP;
use Plack::Loader;
use File::Path qw/rmtree/;
use Plack::Middleware::Static;
use IO::Capture::Stdout;
use File::Read;

require 'nodebrew';

my $data_dir = "$FindBin::Bin/data";
my $brew_dir = "$FindBin::Bin/.nodebrew";

sub clean {
    open my $fh, '>', "$data_dir/nodebrew";
    print $fh 'nodebrew source';
    rmtree $brew_dir;
    rmtree "$data_dir/install";
}

clean();

my $app = sub {
    my $env = shift;

    Plack::Middleware::Static->new({
        path => sub { 1 },
        root => $data_dir,
    })->call($env);
};

sub get_run {
    my $nodebrew = shift;
    my $capture = IO::Capture::Stdout->new;

    return sub {
        my ($command, $args) = @_;
        $capture->start;
        $nodebrew->run($command, $args);
        $capture->stop;
        my $ret = '';
        while (my $line = $capture->read) {
            $ret .= $line;
        }
        return $ret;
    }
}

sub run_test {
    my $url = shift;
    my $nodebrew = Nodebrew->new(
        brew_dir => "$FindBin::Bin/.nodebrew",
        nodebrew_url => "$url/nodebrew",
        remote_list_url => "$url/list.html",
        fetcher => Nodebrew::Fetcher::get('curl'),
        tarballs => [
            "$url/notfound",
            "$url/install/node-{version}.tar.gz",
        ],
    );
    my $run = get_run($nodebrew);
    mkdir $brew_dir;
    my @install_versions = qw/
        v0.1.1
        v0.1.2
        v0.6.0
        v0.6.1
    /;
    for (@install_versions) {
        mkdir "$data_dir/install";
        `cp -R $data_dir/node-base $data_dir/install/node-$_`;
        `cd $data_dir/install && tar -zcf node-$_.tar.gz node-$_`; 
    }

    # before
    ok !-e "$nodebrew->{brew_dir}/nodebrew";
    ok !-e "$nodebrew->{src_dir}";
    ok !-e "$nodebrew->{node_dir}";
    ok !-e "$nodebrew->{default_dir}";
    ok !-e "$nodebrew->{current}";

    # setup
    like $run->('setup'), qr/install nodebrew/;
    is read_file("$nodebrew->{brew_dir}/nodebrew"), 'nodebrew source';
    ok -e "$nodebrew->{src_dir}";
    ok -e "$nodebrew->{node_dir}";
    ok -e "$nodebrew->{default_dir}";
    is readlink "$nodebrew->{current}", "$nodebrew->{default_dir}";

    ok !-e "$nodebrew->{node_dir}/v0.1.1";
    ok !-e "$nodebrew->{src_dir}/node-v0.1.1.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.1.1";
    unlike $run->('list'), qr/v0.1.1/;
    like $run->('list'), qr/not installed/;

    # install
    $run->('install', ['v0.1.1']);
    ok -e "$nodebrew->{node_dir}/v0.1.1";
    ok -e "$nodebrew->{src_dir}/node-v0.1.1.tar.gz";
    ok -e "$nodebrew->{src_dir}/node-v0.1.1";
    like $run->('list'), qr/v0.1.1/;
    like $run->('list'), qr/current: none/;
    is $run->('install', ['v0.1.1']), "v0.1.1 is already installed\n";
    is $run->('install', ['0.1.1']), "v0.1.1 is already installed\n";
    is $run->('install', ['v0.1.3']), "v0.1.3 is not found\n";
    is $run->('install', ['0.1.3']), "v0.1.3 is not found\n";

    $run->('install', ['v0.1.x']);
    like $run->('list'), qr/v0.1.2/;

    $run->('install', ['0.6.0']); # without 'v'
    like $run->('list'), qr/v0.6.0/;

    $run->('install', ['latest']);
    like $run->('list'), qr/v0.6.1/;

    is $run->('install', []), "required version\n";

    # clean
    is $run->('clean', ['v0.1.1']), "clean v0.1.1\n";
    ok !-e "$nodebrew->{src_dir}/node-v0.1.1.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.1.1";
    ok -e "$nodebrew->{src_dir}/node-v0.1.2.tar.gz";
    ok -e "$nodebrew->{src_dir}/node-v0.1.2";
    ok -e "$nodebrew->{src_dir}/node-v0.6.0.tar.gz";
    ok -e "$nodebrew->{src_dir}/node-v0.6.0";
    ok -e "$nodebrew->{src_dir}/node-v0.6.1.tar.gz";
    ok -e "$nodebrew->{src_dir}/node-v0.6.1";

    is $run->('clean', ['0.6.0']), "clean v0.6.0\n"; # without 'v'
    ok !-e "$nodebrew->{src_dir}/node-v0.6.0.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.6.0";

    is $run->('clean', ['all']), "clean all\n";
    ok !-e "$nodebrew->{src_dir}/node-v0.1.2.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.1.2";
    ok !-e "$nodebrew->{src_dir}/node-v0.6.1.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.6.1";

    is $run->('clean', ['v0.1.1']), "v0.1.1 is already cleaned\n";
    is $run->('clean', ['0.1.1']), "v0.1.1 is already cleaned\n";
    is $run->('clean', ['foo']), "foo is already cleaned\n";
    is $run->('clean', []), "required version\n";

    # use
    $run->('use', ['v0.1.1']);
    like $run->('list'), qr/current: v0.1.1/;
    is readlink "$nodebrew->{current}", "$nodebrew->{node_dir}/v0.1.1";

    $run->('use', ['v0.1.x']);
    like $run->('list'), qr/current: v0.1.2/;

    $run->('use', ['0.6.0']); # without 'v'
    like $run->('list'), qr/current: v0.6.0/;

    $run->('use', ['0.1.x']); # without 'v'
    like $run->('list'), qr/current: v0.1.2/;

    $run->('use', ['0.1.1']); # without 'v'
    $run->('use', ['0.1']); # without 'v'
    like $run->('list'), qr/current: v0.1.2/;

    $run->('use', ['latest']);
    like $run->('list'), qr/current: v0.6.1/;

    is $run->('use', ['v0.3.0']), "v0.3.0 is not installed\n";
    is $run->('use', ['0.3.0']), "v0.3.0 is not installed\n";
    is $run->('use', ['foo']), "foo is not installed\n";
    like $run->('list'), qr/current: v0.6.1/;

    is $run->('use', []), "required version\n";

    # ls
    is $run->('list'), $run->('ls');

    # ls-remote
    like $run->('ls-remote'), qr/v0.1.1    v0.1.2/;

    # ls-all
    like $run->('ls-all'), qr/remote:/;
    like $run->('ls-all'), qr/local:/;
    like $run->('ls-all'), qr/current: v0.6.1/;

    # selfupdate
    open my $fh, '>', "$data_dir/nodebrew";
    print $fh 'updated';
    $run->('selfupdate');
    is read_file("$nodebrew->{brew_dir}/nodebrew"), "updated";
    like $run->('list'), qr/current: v0.6.1/;

    # alias
    ok !-e "$nodebrew->{alias_file}";
    is $run->('alias', ['foo', 'bar']), "foo -> bar\n";
    ok -e "$nodebrew->{alias_file}";
    is $run->('alias'), "foo -> bar\n";

    is $run->('alias', ['hoge', 'fuga']), "hoge -> fuga\n";
    is $run->('alias'), "foo -> bar\nhoge -> fuga\n";

    is $run->('alias', ['foo', 'baz']), "foo -> baz\n";
    is $run->('alias'), "foo -> baz\nhoge -> fuga\n";

    is $run->('alias', ['baz']), "baz is not set alias\n";
    is $run->('alias', ['foo']), "foo -> baz\n";

    $run->('alias', ['foo', 'v0.6.0']);
    $run->('use', ['foo']);
    like $run->('list'), qr/current: v0.6.0/;

    $run->('alias', ['0.6', '0.6.x']);
    $run->('use', ['0.6']);
    like $run->('list'), qr/current: v0.6.1/;

    is $run->('unalias', ['foo']), "remove foo\n";
    is $run->('alias'), "0.6 -> 0.6.x\nhoge -> fuga\n";

    is $run->('unalias', ['foo']), "not register foo\n";

    # uninstall
    is $run->('uninstall', ['v0.6.1']), "v0.6.1 uninstalled\n";
    ok !-e "$nodebrew->{node_dir}/v0.6.1";
    unlike $run->('list'), qr/v0.6.1/;
    like $run->('list'), qr/current: none/;
    is readlink "$nodebrew->{current}", "$nodebrew->{default_dir}";

    is $run->('uninstall', ['v0.6.1']), "v0.6.1 is not installed\n";
    is $run->('uninstall', ['foo']), "foo is not installed\n";
    is $run->('uninstall', ['0.6.0']), "v0.6.0 uninstalled\n"; # without v
    ok !-e "$nodebrew->{node_dir}/v0.6.0";

    is $run->('uninstall', []), "required version\n";

    # help
    like $run->('help'), qr/Usage:/;
    is $run->(), $run->('help');
    is $run->('invalid command'), $run->('help');

    # clean
    clean();
}

test_tcp(
    client => sub {
        my $port = shift;
        my $url = "http://127.0.0.1:$port";
        run_test($url);
    },
    server => sub {
        my $port   = shift;
        my $server = Plack::Loader->auto(
            port => $port,
            host => '127.0.0.1',
        );
        $server->run($app);
    },
);

done_testing;
