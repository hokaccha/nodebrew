package Nodebrew::Utils;
use strict;
use warnings;

use POSIX;
use Cwd 'getcwd';

sub sort_version {
    my $version = shift;

    return [sort {
        my ($a1, $a2, $a3) = ($a =~ m/v(\d+)\.(\d+)\.(\d+)/);
        my ($b1, $b2, $b3) = ($b =~ m/v(\d+)\.(\d+)\.(\d+)/);
        $a1 <=> $b1 || $a2 <=> $b2 || $a3 <=> $b3
    } @$version];
}

sub find_version {
    my ($version, $versions) = @_;

    $versions = Nodebrew::Utils::sort_version($versions);
    my @versions = @$versions;

    return undef unless scalar @versions;
    return pop @versions if $version eq 'latest' || $version eq 'stable';

    my @v = map {
        $_ && $_ eq 'x' ? undef : $_
    } $version =~ m/^v(\d+)\.?(\d+|x)?\.?(\d+|x)?$/;

    my @ret;
    if (defined($v[0]) && defined($v[1]) && defined($v[2])) {
        @ret = grep { /^v?$v[0]\.$v[1]\.$v[2]$/ } @versions;
    }
    elsif (defined($v[0]) && defined($v[1]) && !defined($v[2])) {
        @ret = grep { /^v?$v[0]\.$v[1]\./ } @versions;
    }
    elsif (defined($v[0]) && !defined($v[1])) {
        @ret = grep { /^v?$v[0]\./ } @versions;
    }

    pop @ret;
}

sub parse_args {
    my $command = shift;

    return ($command, \@_);
}

sub system_info {
    my $arch;
    my ($sysname, $machine) = (POSIX::uname)[0, 4];

    if  ($machine =~ m/x86_64/) {
        $arch = 'x64';
    } elsif ($machine =~ m/i\d86/) {
        $arch = 'x86';
    } elsif ($machine =~ m/armv6l/) {
        $arch = 'armv6l';
    } elsif ($machine =~ m/armv7l/) {
        $arch = 'armv7l';
    } elsif ($sysname =~ m/sunos/i) {
        # SunOS $machine => 'i86pc'. but use 64bit kernel.
        # Solaris 11 not support 32bit kernel.
        # both 32bit and 64bit node-binary even work on 64bit kernel
        $arch = 'x64';
    } else {
        die "Error: $sysname $machine is not supported."
    }

    return (lc $sysname, $arch);
}

sub apply_vars {
    my ($str, $hash) = @_;

    for my $key (keys %$hash) {
        my $val = $hash->{$key};

        $str =~ s/#\{$key\}/$val/g;
    }

    return $str;
}

sub extract_tar {
    my ($filepath, $outdir) = @_;

    my $cwd = getcwd;

    chdir($outdir);

    eval {
        require Archive::Tar;
        my $tar = Archive::Tar->new;
        $tar->read($filepath);
        $tar->extract;
    };
    if ($@) {
        `tar zfx $filepath`;
    }

    chdir($cwd);
}

1;
