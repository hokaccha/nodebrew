use strict;
use warnings;
use Test::More;
use FindBin;
use Cwd 'abs_path';
use File::Path qw/rmtree/;

plan skip_all => "Live Test" unless $ENV{LIVE_TEST};

my $nodebrew_root = "$FindBin::Bin/.nodebrew";
my $nodebrew = abs_path("$FindBin::Bin/../nodebrew");
$ENV{PATH} = "$nodebrew_root/current/bin:$ENV{PATH}";
$ENV{NODEBREW_ROOT} = $nodebrew_root;

system "$nodebrew setup";

system "$nodebrew install-binary v0.10.0";
system "$nodebrew install-binary v0.11.0";
system "$nodebrew use v0.10.0";

is `node -v`, "v0.10.0\n";
is `$nodebrew exec v0.11.0 -- node -v`, "v0.11.0\n";

rmtree $nodebrew_root;

done_testing;
