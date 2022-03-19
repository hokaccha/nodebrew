use strict;
use warnings;

use t::Util;
use Test::More;

my $nodebrew = init_nodebrew();
$nodebrew->run('setup');
$nodebrew->run('install', ['v8.9.0']);
$nodebrew->run('install', ['v8.9.4']);
$nodebrew->run('install', ['v6.2.0']);
$nodebrew->run('install', ['v6.2.1']);
$nodebrew->run('use', ['v8.9.0']); # not the latest, but should be kept

is $nodebrew->run('prune', ['--dry-run']), <<'EOT';
v6:
  keeping: v6.2.1
  removing: [v6.2.0]
v8:
  keeping: v8.9.4
  removing: [v8.9.0]
EOT

ok -e "$nodebrew->{node_dir}/v6.2.0", "old version is not uninstalled because --dry-run is set";

is $nodebrew->run('prune'), <<'EOT';
v6:
  keeping: v6.2.1
  removing: [v6.2.0]
v8:
  keeping: v8.9.4
  removing: [v8.9.0]
v6.2.0 uninstalled
v8.9.0 uninstalled
EOT

ok !-e "$nodebrew->{node_dir}/v6.2.0";
ok -e "$nodebrew->{node_dir}/v6.2.1";
ok !-e "$nodebrew->{node_dir}/v8.9.0";
ok -e "$nodebrew->{node_dir}/v8.9.4";

done_testing;
