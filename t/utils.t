use strict;
use warnings;
use Test::More;
use POSIX;

require 'nodebrew';

my $versions = [
    'v0.5.0',
    'v0.10.0',
    'v0.0.1',
    'v0.0.2',
    'v0.1.0',
    'v0.1.1',
    'v0.1.2',
    'v0.1.10',
    'v1.0.0',
    'v2.0.0',
    'v10.0.0',
    'v1.1.0',
    'v2.0.1',
];

is_deeply Nodebrew::Utils::sort_version($versions), [
    'v0.0.1',
    'v0.0.2',
    'v0.1.0',
    'v0.1.1',
    'v0.1.2',
    'v0.1.10',
    'v0.5.0',
    'v0.10.0',
    'v1.0.0',
    'v1.1.0',
    'v2.0.0',
    'v2.0.1',
    'v10.0.0',
];

is Nodebrew::Utils::find_version('latest', $versions), 'v10.0.0';
is Nodebrew::Utils::find_version('stable', $versions), 'v10.0.0';
is Nodebrew::Utils::find_version('v0.1.x', $versions), 'v0.1.10';
is Nodebrew::Utils::find_version('v0.1', $versions), 'v0.1.10';
is Nodebrew::Utils::find_version('v0', $versions), 'v0.10.0';
is Nodebrew::Utils::find_version('v2', $versions), 'v2.0.1';
is Nodebrew::Utils::find_version('v1.x', $versions), 'v1.1.0';
is Nodebrew::Utils::find_version('v0.x.1', $versions), 'v0.10.0';
is Nodebrew::Utils::find_version('v0.5.0', $versions), 'v0.5.0';
is Nodebrew::Utils::find_version('v0.5.1', $versions), undef;
is Nodebrew::Utils::find_version('v0.6', $versions), undef;
is Nodebrew::Utils::find_version('v0.6.x', $versions), undef;
is Nodebrew::Utils::find_version('v0.6.0', []), undef;
is_deeply $versions, [
    'v0.5.0',
    'v0.10.0',
    'v0.0.1',
    'v0.0.2',
    'v0.1.0',
    'v0.1.1',
    'v0.1.2',
    'v0.1.10',
    'v1.0.0',
    'v2.0.0',
    'v10.0.0',
    'v1.1.0',
    'v2.0.1',
];

is Nodebrew::Utils::find_version('stable', [
    'v0.0.1',
    'v1.5.0',
    'v4.1.0']), 'v4.1.0';

is Nodebrew::Utils::find_version('stable', [
    'v8.9.1',
    'v10.0.0']), 'v10.0.0';

{
    my ($command, $args, $opt)
      = Nodebrew::Utils::parse_args('install', '0.1');

    is $command, 'install';
    is $args->[0], '0.1';
}

is Nodebrew::Utils::apply_vars('key-#{key1}-#{key2}-#{key1}', {
    key1 => 'val1',
    key2 => 'val2',
}), 'key-val1-val2-val1';

{
    no warnings;
    *POSIX::uname = sub {
        return ('FOO', undef, undef, undef, 'i686');
    };
    my ($sysname, $arch) = Nodebrew::Utils::system_info();
    is $sysname, 'foo';
    is $arch, 'x86';
}

{
    no warnings;
    *POSIX::uname = sub {
        return ('FOO', undef, undef, undef, 'i386');
    };
    my ($sysname, $arch) = Nodebrew::Utils::system_info();
    is $arch, 'x86';
}

{
    no warnings;
    *POSIX::uname = sub {
        return ('FOO', undef, undef, undef, 'x86_64');
    };
    my ($sysname, $arch) = Nodebrew::Utils::system_info();
    is $arch, 'x64';
}

{
    no warnings;
    *POSIX::uname = sub {
        return ('FOO', undef, undef, undef, 'armv6l');
    };
    my ($sysname, $arch) = Nodebrew::Utils::system_info();
    is $arch, 'armv6l';
}

{
    no warnings;
    *POSIX::uname = sub {
        return ('FOO', undef, undef, undef, 'armv7l');
    };
    my ($sysname, $arch) = Nodebrew::Utils::system_info();
    is $arch, 'armv7l';
}

{
    no warnings;
    *POSIX::uname = sub {
        return ('sunos', undef, undef, undef, 'foo');
    };
    my ($sysname, $arch) = Nodebrew::Utils::system_info();
    is $arch, 'x64';
}

{
    no warnings;
    *POSIX::uname = sub {
        return ('sysname', undef, undef, undef, 'machine');
    };
    eval {
        Nodebrew::Utils::system_info();
    };

    like $@, qr/^Error: sysname machine is not supported./;
}


done_testing;
