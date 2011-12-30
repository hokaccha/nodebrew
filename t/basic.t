use strict;
use warnings;
use Test::More;
use FindBin;

require 'nodebrew';

my $brew_dir = "$FindBin::Bin/.nodebrew";
my $nodebrew_url = 'http://127.0.0.1:8000/install';
my $fetcher = Nodebrew::Fetcher::get('curl');
my $nodebrew = Nodebrew->new(
    brew_dir => $brew_dir,
    nodebrew_url => $nodebrew_url,
    fetcher => $fetcher,
);

is $nodebrew->{brew_dir}, $brew_dir;
is $nodebrew->{src_dir}, "$brew_dir/src";
is $nodebrew->{node_dir}, "$brew_dir/node";
is $nodebrew->{current}, "$brew_dir/current";
is $nodebrew->{default_dir}, "$brew_dir/default";
is $nodebrew->{nodebrew_url}, $nodebrew_url;
is $nodebrew->{fetcher}, $fetcher;

done_testing;
