package Nodebrew::Fetcher::Wget;
use strict;
use warnings;

sub new { bless {}; }

sub fetch_able {
    my ($self, $url) = @_;

    `wget -Sq --spider "$url" 2>&1` =~ m/200 OK/;
}

sub fetch {
    my ($self, $url) = @_;

    `wget -q $url -O -`;
}

sub download {
    my ($self, $url, $path) = @_;

    system("wget -c $url -O $path") == 0;
}

1;
