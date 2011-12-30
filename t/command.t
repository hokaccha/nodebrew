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

my $app = sub {
    my $env = shift;

    Plack::Middleware::Static->new({
        path => sub { 1 },
        root => "$FindBin::Bin/data",
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
            "$url/node-{version}.tar.gz",
        ],
    );
    my $run = get_run($nodebrew);
    mkdir $brew_dir;

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

    ok !-e "$nodebrew->{node_dir}/v0.0.0";
    ok !-e "$nodebrew->{src_dir}/node-v0.0.0.tar.gz";
    ok !-e "$nodebrew->{src_dir}/node-v0.0.0";
    unlike $run->('list'), qr/v0.0.0/;
    like $run->('list'), qr/not installed/;

    # install
    $run->('install', ['v0.0.0']);
    ok -e "$nodebrew->{node_dir}/v0.0.0";
    ok -e "$nodebrew->{src_dir}/node-v0.0.0.tar.gz";
    ok -e "$nodebrew->{src_dir}/node-v0.0.0";
    like $run->('list'), qr/v0.0.0/;
    like $run->('list'), qr/current: none/;
    is $run->('install', ['v0.0.0']), "v0.0.0 is already installed\n";
    is $run->('install', ['v0.0.1']), "v0.0.1 is not found\n";

    # use
    $run->('use', ['v0.0.0']);
    like $run->('list'), qr/current: v0.0.0/;
    is readlink "$nodebrew->{current}", "$nodebrew->{node_dir}/v0.0.0";

    # ls
    is $run->('list'), $run->('ls');

    # ls-remote
    like $run->('ls-remote'), qr/v0.0.1    v0.0.2    v0.0.3    v0.0.4    v0.0.5    v0.0.6/;

    # selfupdate
    open my $fh, '>', "$FindBin::Bin/data/nodebrew";
    print $fh 'updated';
    $run->('selfupdate');
    is read_file("$nodebrew->{brew_dir}/nodebrew"), "updated";
    like $run->('list'), qr/current: v0.0.0/;

    # uninstall
    is $run->('uninstall', ['v0.0.0']), "v0.0.0 uninstalled\n";
    is $run->('uninstall', ['v0.0.0']), "v0.0.0 is not installed\n";
    ok !-e "$nodebrew->{node_dir}/v0.0.0";
    like $run->('list'), qr/not installed/;
    like $run->('list'), qr/current: none/;
    is readlink "$nodebrew->{current}", "$nodebrew->{default_dir}";

    # help
    like $run->('help'), qr/Usage:/;
    is $run->(), $run->('help');
    is $run->('invalid command'), $run->('help');

    # clean
    open $fh, '>', "$FindBin::Bin/data/nodebrew";
    print $fh 'nodebrew source';
    rmtree $brew_dir;
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
