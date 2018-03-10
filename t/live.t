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

system "$nodebrew install v8.9.0";
system "$nodebrew install-binary v8.9.1";
system "$nodebrew compile v8.9.2";

like `$nodebrew ls`, qr/v8.9.0/;
like `$nodebrew ls`, qr/v8.9.1/;
like `$nodebrew ls`, qr/v8.9.2/;

system "$nodebrew use v8.9.0";
is `node -v`, "v8.9.0\n";

system "$nodebrew use v8.9.1";
is `node -v`, "v8.9.1\n";

system "$nodebrew use v8.9.2";
is `node -v`, "v8.9.2\n";

is `$nodebrew exec v8.9.0 -- node -v`, "v8.9.0\n";

rmtree $nodebrew_root;

done_testing;
