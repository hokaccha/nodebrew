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
    my $brew_dir = "$FindBin::Bin/.nodebrew";
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
    is $run->('install', ['v0.1.3']), "v0.1.3 is not found\n";

    $run->('install', ['v0.1.x']);
    like $run->('list'), qr/v0.1.2/;

    $run->('install', ['latest']);
    like $run->('list'), qr/v0.6.1/;

    # clean
    $run->('clean', ['v0.1.1']);
    ok !-e "$nodebrew->{src_dir}/node-v0.1.1.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.1.1";
    ok -e "$nodebrew->{src_dir}/node-v0.1.2.tar.gz";
    ok -e "$nodebrew->{src_dir}/node-v0.1.2";
    ok -e "$nodebrew->{src_dir}/node-v0.6.1.tar.gz";
    ok -e "$nodebrew->{src_dir}/node-v0.6.1";
    $run->('clean', ['all']);
    ok !-e "$nodebrew->{src_dir}/node-v0.1.2.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.1.2";
    ok !-e "$nodebrew->{src_dir}/node-v0.6.1.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.6.1";

    # use
    $run->('use', ['v0.1.1']);
    like $run->('list'), qr/current: v0.1.1/;
    is readlink "$nodebrew->{current}", "$nodebrew->{node_dir}/v0.1.1";

    $run->('use', ['v0.1.x']);
    like $run->('list'), qr/current: v0.1.2/;

    $run->('use', ['latest']);
    like $run->('list'), qr/current: v0.6.1/;

    is $run->('use', ['v0.3.0']), "v0.3.0 is not installed\n";
    like $run->('list'), qr/current: v0.6.1/;

    is $run->('use', ['foo']), "foo is not installed\n";
    like $run->('list'), qr/current: v0.6.1/;

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

    # uninstall
    is $run->('uninstall', ['v0.6.1']), "v0.6.1 uninstalled\n";
    is $run->('uninstall', ['v0.6.1']), "v0.6.1 is not installed\n";
    ok !-e "$nodebrew->{node_dir}/v0.6.1";
    unlike $run->('list'), qr/v0.6.1/;
    like $run->('list'), qr/current: none/;
    is readlink "$nodebrew->{current}", "$nodebrew->{default_dir}";

    # help
    like $run->('help'), qr/Usage:/;
    is $run->(), $run->('help');
    is $run->('invalid command'), $run->('help');

    # clean
    open $fh, '>', "$data_dir/nodebrew";
    print $fh 'nodebrew source';
    rmtree $brew_dir;
    rmtree "$data_dir/install";
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
