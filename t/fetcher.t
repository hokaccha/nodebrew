use strict;
use warnings;
use Test::More;
use Test::TCP;
use Plack::Loader;
use FindBin;
use File::Path qw/rmtree/;
use File::Read;

require 'nodebrew';

my $app = sub {
    my $env = shift;
    my $content;
    my $status;

    if ($env->{REQUEST_URI} eq '/') {
        $content = 'success';
        $status = 200;
    }
    else {
        $status = 404;
    }

    return [ $status, [ 'Content-Type' => 'text/plain' ], [ $content ] ];
};

my $client = sub {
    my ($url, $type) = @_;
    my $fetcher = Nodebrew::Fetcher::get($type);

    ok $fetcher->fetch_able($url);
    ok !$fetcher->fetch_able("$url/notfound");
    is $fetcher->fetch($url), 'success';

    my $tmp_dir = "$FindBin::Bin/tmp";
    mkdir $tmp_dir;
    my $filepath = "$tmp_dir/test.txt";
    ok !-e $filepath;
    $fetcher->download($url, $filepath);
    ok -e $filepath;
    is read_file($filepath), 'success';
    rmtree $tmp_dir;
};

test_tcp(
    client => sub {
        my $port = shift;
        my $url = "http://127.0.0.1:$port";
        $client->($url, 'curl');
        $client->($url, 'wget');
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
