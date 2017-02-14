package Nodebrew::Fetcher;
use strict;
use warnings;

use FindBin;

my $base_dir;
BEGIN {
    $base_dir = "$FindBin::Bin/lib";
}

require "$base_dir/Nodebrew/Fetcher/cURL/cURL.pm";
require "$base_dir/Nodebrew/Fetcher/Wget/Wget.pm";

sub get {
    my $type = shift;

    $type eq 'wget' ? Nodebrew::Fetcher::Wget->new:
    $type eq 'curl' ? Nodebrew::Fetcher::cURL->new:
    die 'Fetcher type invalid';
}

1;
