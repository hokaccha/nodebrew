package t::Util;

use strict;
use warnings;

use Exporter 'import';
use Test::TCP;
use FindBin;
use Plack::Loader;
use File::Path qw/rmtree/;
use Plack::Middleware::Static;
use IO::Capture::Stdout;
use File::Read;
use Test::MockObject::Extends;

require 'nodebrew';

our @EXPORT = qw/init_nodebrew $data_dir $brew_dir/;

our $data_dir = "$FindBin::Bin/data";
our $brew_dir = "$FindBin::Bin/.nodebrew";

{
    no warnings;
    *Nodebrew::error_and_exit = sub {
        my $msg = shift;
        print "$msg\n";
        die; # instead of exit
    };

    *Nodebrew::Utils::system_info = sub {
        return ('linux', 'x86');
    };
}

sub init_nodebrew {
    clean();
    setup();

    my $port = init_server()->port;
    my $url = "http://127.0.0.1:$port";

    my $nodebrew = Nodebrew->new(
        brew_dir => "$FindBin::Bin/.nodebrew",
        nodebrew_url => "$url/nodebrew",
        bash_completion_url => "$url/completions/bash/nodebrew-completion",
        zsh_completion_url => "$url/completions/zsh/_nodebrew",
        fetcher => Nodebrew::Fetcher::get('curl'),
        remote_list_url => {
            node => "$url/list.html",
            iojs => "$url/iolist.html",
        },
        tarballs => {
            node => [
                "$url/notfound",
                "$url/install/node-#{version}.tar.gz",
            ],
            iojs => [
                "$url/notfound",
                "$url/install/iojs-#{version}.tar.gz",
            ],
        },
        tarballs_binary => {
            node => [
                "$url/notfound",
                "$url/install/node-#{version}-#{platform}-#{arch}.tar.gz",
            ],
            iojs => [
                "$url/notfound",
                "$url/install/iojs-#{version}-#{platform}-#{arch}.tar.gz",
            ],
        },
    );

    my $mock = Test::MockObject::Extends->new($nodebrew);
    $mock->mock('run', sub {
        my $capture = IO::Capture::Stdout->new;

        $capture->start;
        eval {
            Nodebrew::run(@_);
        };
        $capture->stop;

        warn $@ if $@;
        my $ret = '';
        while (my $line = $capture->read) {
            $ret .= $line;
        }

        return $ret;
    });
    
    return $mock;
}

my $server;
sub init_server {
    return $server if $server;

    my $app = sub {
        my $env = shift;

        Plack::Middleware::Static->new({
            path => sub { 1 },
            root => $data_dir,
        })->call($env);
    };

    $server = Test::TCP->new(
        code => sub {
            my $port   = shift;
            my $server = Plack::Loader->auto(
                port => $port,
                host => '127.0.0.1',
            );
            $server->run($app);
        },
    );

    return $server;
}

sub setup {
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

    `cp -R $data_dir/node-binary-base $data_dir/install/node-v0.4.0-linux-x86`;
    `cd $data_dir/install && tar -zcf node-v0.4.0-linux-x86.tar.gz node-v0.4.0-linux-x86`;
}

sub clean {
    open my $fh, '>', "$data_dir/nodebrew";
    print $fh 'nodebrew source';
    rmtree $brew_dir;
    rmtree "$data_dir/install";
}

sub END {
    clean();
}

1;
