use strict;
use warnings;
use Test::More;
use FindBin;
use Cwd 'abs_path';
use File::Path qw/rmtree/;

my $nodebrew_root = "$FindBin::Bin/.nodebrew";
my $nodebrew = abs_path("$FindBin::Bin/../nodebrew");
my $command = "NODEBREW_ROOT=$nodebrew_root $nodebrew";

system "$command setup";
system "$command install-binary v0.8.15";
system "$command use v0.8.15";
is `$nodebrew_root/current/bin/node -v`, "v0.8.15\n";

rmtree $nodebrew_root;

done_testing;
