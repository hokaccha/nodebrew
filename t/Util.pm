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

{
    no warnings;
    *Nodebrew::Utils::system_info = sub {
        return ('linux', 'x86');
    };
}

our @EXPORT = qw/init_nodebrew $data_dir $brew_dir/;

our $data_dir = "$FindBin::Bin/data";
our $brew_dir = "$FindBin::Bin/.nodebrew";

{
    no warnings;
    *Nodebrew::error_and_exit = sub {
        my $msg = shift;
        print "$msg\n";
        die $msg; # instead of exit
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
        fish_completion_url => "$url/completions/fish/nodebrew.fish",
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
                "$url/install/#{release}/iojs-#{version}.tar.gz",
            ],
        },
        tarballs_binary => {
            node => [
                "$url/notfound",
                "$url/install/node-#{version}-#{platform}-#{arch}.tar.gz",
            ],
            iojs => [
                "$url/notfound",
                "$url/install/#{release}/iojs-#{version}-#{platform}-#{arch}.tar.gz",
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
    my @source_versions = qw/
        v8.9.0
        v8.9.4
    /;
    my @binary_versions = qw/
        v6.2.0
        v6.2.1
        v8.9.0
        v8.9.4
    /;

    for (@source_versions) {
        mkdir "$data_dir/install";
        `cp -R $data_dir/node-base $data_dir/install/node-$_`;
        `cd $data_dir/install && tar -zcf node-$_.tar.gz node-$_`; 
    }

    for (@binary_versions) {
        `cp -R $data_dir/node-binary-base $data_dir/install/node-$_-linux-x86`;
        `cd $data_dir/install && tar -zcf node-$_-linux-x86.tar.gz node-$_-linux-x86`;
    }

    mkdir "$data_dir/install/release";
    `cp -R $data_dir/release/iojs-binary-base $data_dir/install/release/iojs-v1.0.0-linux-ia32`;
    `cd $data_dir/install/release && tar -zcf iojs-v1.0.0-linux-x86.tar.gz iojs-v1.0.0-linux-ia32`;

    mkdir "$data_dir/install/next-nightly";
    `cp -R $data_dir/next-nightly/iojs-binary-base $data_dir/install/next-nightly/iojs-v3.0.0-next-nightly20150717cbec3ee19d-linux-ia32`;
    `cd $data_dir/install/next-nightly && tar -zcf iojs-v3.0.0-next-nightly20150717cbec3ee19d-linux-x86.tar.gz iojs-v3.0.0-next-nightly20150717cbec3ee19d-linux-ia32`;
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
