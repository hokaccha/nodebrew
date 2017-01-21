package Nodebrew::Fetcher::cURL;
use strict;
use warnings;

sub new { bless {}; }

sub fetch_able {
    my ($self, $url) = @_;

    `curl -LIs "$url"` =~ m/200 OK/;
}

sub fetch {
    my ($self, $url) = @_;

    `curl -Ls $url`;
}

sub download {
    my ($self, $url, $path) = @_;

    system("curl -C - --progress-bar $url -o $path") == 0;
}

1;
