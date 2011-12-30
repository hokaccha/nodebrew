use strict;
use warnings;
use Test::More;
use FindBin;
use Cwd 'abs_path';
use File::Path qw/rmtree/;

unless ($ENV{LIVE_TEST}) {
    plan skip_all => 'Live test';
    exit;
}

my $nodebrew_root = "$FindBin::Bin/.nodebrew";
my $nodebrew = abs_path("$FindBin::Bin/../nodebrew");
my $command = "NODEBREW_ROOT=$nodebrew_root $nodebrew";

like `$command setup`, qr/install nodebrew/;
like `$command list`, qr/current: none/;
system "$command install v0.4.0";
system "$command install v0.6.0";

like `$command list`, qr/v0.4.0/;
like `$command list`, qr/v0.6.0/;

system "$command use v0.6.0";
like `$command list`, qr/current: v0.6.0/;
like `$nodebrew_root/current/bin/node -v`, qr/v0.6.0/;

system "$command use v0.4.0";
like `$command list`, qr/current: v0.4.0/;
like `$nodebrew_root/current/bin/node -v`, qr/v0.4.0/;

rmtree $nodebrew_root;

done_testing;
