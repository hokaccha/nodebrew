use strict;
use warnings;
use Test::More;
use FindBin;

require 'nodebrew';

my $brew_dir = "$FindBin::Bin/.nodebrew";
my $fetcher = Nodebrew::Fetcher::get('curl');
my $nodebrew = Nodebrew->new(
    brew_dir => $brew_dir,
    fetcher => $fetcher,
);

is $nodebrew->{brew_dir}, $brew_dir;
is $nodebrew->{src_dir}, "$brew_dir/src";
is $nodebrew->{node_dir}, "$brew_dir/node";
is $nodebrew->{current}, "$brew_dir/current";
is $nodebrew->{default_dir}, "$brew_dir/default";
is $nodebrew->{fetcher}, $fetcher;

done_testing;
