use strict;
use warnings;
use Test::More;
use Test::TCP;
use Plack::Loader;

require 'nodebrew';

my $app = sub {
    my $env = shift;
    return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'foo' ] ];
};

my $client = sub {
    my $url = shift;
    my $fetcher = Nodebrew::Fetcher->new('curl');
    is $fetcher->fetch($url), 'foo';
};

test_tcp(
    client => sub {
        my $port = shift;
        my $url = "http://127.0.0.1:$port";
        $client->($url);
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
