package Nodebrew;
use strict;
use warnings;
our $VERSION = '0.9.6';

use File::Path qw/rmtree mkpath/;
use File::Basename qw/basename/;

use FindBin;

my $base_dir;
BEGIN {
    $base_dir = "$FindBin::Bin/lib";
}

require "$base_dir/Nodebrew/Config/Config.pm";
require "$base_dir/Nodebrew/Fetcher/Fetcher.pm";
require "$base_dir/Nodebrew/Utils/Utils.pm";

sub new {
    my $class = shift;
    my %opt = @_;
    my $self = {};
    my @props = qw/
        brew_dir
        nodebrew_url
        bash_completion_url
        zsh_completion_url
        fish_completion_url
        fetcher
        remote_list_url
        tarballs
        tarballs_binary
    /;

    for (@props) {
        if (defined $opt{$_}) {
            $self->{$_} = $opt{$_};
        }
        else {
            die "required $_";
        }
    }

    bless $self, $class;
    $self->init();

    return $self;
}

sub init {
    my $self = shift;

    $self->{src_dir} = $self->{brew_dir} . '/src';
    $self->{node_dir} = $self->{brew_dir} . '/node';
    $self->{iojs_dir} = $self->{brew_dir} . '/iojs';
    $self->{current} = $self->{brew_dir} . '/current';
    $self->{default_dir} = $self->{brew_dir} . '/default';
    $self->{alias_file} = $self->{brew_dir} . '/alias';
    $self->{bash_completion_dir} = $self->{brew_dir} . '/completions/bash';
    $self->{zsh_completion_dir} = $self->{brew_dir} . '/completions/zsh';
    $self->{fish_completion_dir} = $self->{brew_dir} . '/completions/fish';
}

sub run {
    my ($self, $command, $args) = @_;

    $command ||= '';
    $command =~ s/-/_/g;

    if (my $cmd = $self->can("_cmd_$command")) {
        $cmd->($self, $args);
    }
    else {
        $self->_cmd_help($args);
    }
}

sub _cmd_use {
    my ($self, $args) = @_;

    my $version = $self->find_available_version($args->[0]);
    my $target = Nodebrew::Utils::get_install_dir() . "/$version";
    my $nodebrew_path = "$target/bin/nodebrew";

    unlink $self->{current} if -l $self->{current};
    symlink $target, $self->{current};
    symlink "$self->{brew_dir}/nodebrew", $nodebrew_path unless -l $nodebrew_path;
    my $prefix = $self->is_iojs ? 'io@' : '';
    print "use $prefix$version\n";
}

sub _cmd_install {
    my ($self, $args) = @_;

    my $v = shift @$args;
    my $configure_opts = join ' ', @$args;
    my ($version, $release) = $self->find_install_version($v);
    my $opts = +{ release => $release || "release" };
    my $tarball_url = $self->get_tarball($self->get_tarballs_url, $version, $opts);
    my $src_dir = "$self->{src_dir}/$version";
    my $target_name = $self->get_type . "-$version";
    my $tarball_path = "$src_dir/$target_name.tar.gz";

    $self->clean($version);
    mkdir $src_dir;

    print "Fetching: $tarball_url\n";
    $self->{fetcher}->download($tarball_url, $tarball_path)
        or error_and_exit("download failed: $tarball_url");

    Nodebrew::Utils::extract_tar($tarball_path, $src_dir);

    my $install_dir = Nodebrew::Utils::get_install_dir();
    system qq[
        cd "$src_dir/$target_name" &&
        ./configure --prefix="$install_dir/$version" $configure_opts &&
        make &&
        make install
    ];
}

sub _cmd_install_binary {
    my ($self, $args) = @_;

    my ($version, $release) = $self->find_install_version($args->[0]);
    my ($platform, $arch) = Nodebrew::Utils::system_info();
    if ($arch eq 'armv6l' && $version =~ m/v0\.\d+\.\d+/) {
        # nodev0.x.x on armv6l(RaspberryPi1)
        $arch = 'arm-pi';
    }
    my $tarball_url = $self->get_tarball($self->get_tarballs_binary_url, $version, {
        platform => $platform,
        arch     => $arch,
        release  => $release || "release"
    });
    my $type = $self->get_type();
    my $src_dir = "$self->{src_dir}/$version";
    my $target_name = "$type-$version-$platform-$arch";
    my $tarball_path = "$src_dir/$target_name.tar.gz";

    $self->clean($version);
    mkdir $src_dir;

    print "Fetching: $tarball_url\n";
    $self->{fetcher}->download($tarball_url, $tarball_path)
        or error_and_exit("download failed: $tarball_url");

    Nodebrew::Utils::extract_tar($tarball_path, $src_dir);

    # https://github.com/hokaccha/nodebrew/issues/34
    if ($type eq 'iojs' && $platform eq 'linux' && $arch eq 'x86') {
        $target_name =~ s/x86$/ia32/;
    }

    rename "$src_dir/$target_name", Nodebrew::Utils::get_install_dir() . "/$version" or die "Error: $!";

    print "Installed successfully\n";
}

sub _cmd_uninstall {
    my ($self, $args) = @_;
    my $version = Nodebrew::Utils::normalize_version($args->[0]);
    my $target = Nodebrew::Utils::get_install_dir() . "/$version";
    my $current_version = $self->get_current_version();

    error_and_exit("$version is not installed") unless -e $target;
    rmtree $target;

    $version = "io\@$version" if ($self->is_iojs);
    if ($current_version eq $version) {
        $self->use_default();
    }

    print "$version uninstalled\n";
}

sub _cmd_list {
    my ($self, $args) = @_;

    my @node_versions = @{$self->get_local_version('node')};
    my @iojs_versions = map { "io\@$_"; } @{$self->get_local_version('iojs')};
    my @versions;
    push @versions, @node_versions, @iojs_versions;

    print scalar @versions
        ? join("\n", @{Nodebrew::Utils::sort_version(\@versions)})
        : "not installed";
    print "\n\ncurrent: " . $self->get_current_version() . "\n";
}

sub _cmd_ls {
    my ($self, $args) = @_;

    $self->_cmd_list($args);
}

sub _cmd_ls_remote {
    my ($self, $args) = @_;

    my @node_versions = @{Nodebrew::Utils::sort_version($self->get_remote_version('node'))};
    my @iojs_versions = map { "io\@$_"; } @{Nodebrew::Utils::sort_version($self->get_remote_version('iojs'))};
    my @versions;
    push @versions, @node_versions, @iojs_versions;

    my $i = 0;
    my %tmp;

    for (@versions) {
        my ($v1, $v2, $v3) = $_ =~ m/v(\d+)\.(\d+)\.(\d+)/;
        if ($v1 == 0 && !$tmp{"$v1.$v2"}++) {
            print "\n\n" if $i;
            $i = 0;
        }
        elsif ($v1 != 0 && !$tmp{"$v1"}++) {
            print "\n\n" if $i;
            $i = 0;
        }

        print $_;
        print ++$i % 8 == 0 ? "\n" : ' ' x (10 - length $_);
    }
    print "\n";
}

sub _cmd_ls_all {
    my ($self, $args) = @_;

    print "remote:\n";
    $self->_cmd_ls_remote($args);
    print "\nlocal:\n";
    $self->_cmd_ls($args);
}

sub _cmd_alias {
    my ($self, $args) = @_;

    my ($key, $val)  = $args ? @$args : ();
    my $alias = Nodebrew::Config->new($self->{alias_file});

    # set alias
    if ($key && $val) {
        $alias->set($key, $val);
        $alias->save();
        print "$key -> $val\n";
    }
    # get alias
    elsif ($key) {
        $val = $alias->get($key);
        print $val ? "$key -> $val\n" : "$key is not set alias\n";
    }
    # get alias all
    else {
        my $datas = $alias->get_all();
        for (keys %{$datas}) {
            print $_ . ' -> ' . $datas->{$_} . "\n";
        }
    }
}

sub _cmd_unalias {
    my ($self, $args) = @_;

    my $alias = Nodebrew::Config->new($self->{alias_file});
    my $key = $args->[0];
    if (!$key) {
        return;
    }

    if ($alias->del($key)) {
        $alias->save();
        print "Removed $key\n";
    }
    else {
        error_and_exit("$key is not defined");
    }
}

sub _cmd_setup {
    my ($self, $args) = @_;

    $self->_cmd_setup_dirs();

    my $nodebrew_path = "$self->{brew_dir}/nodebrew";
    $self->fetch_nodebrew();
    `chmod +x $nodebrew_path`;
    symlink $nodebrew_path, "$self->{default_dir}/bin/nodebrew";
    $self->use_default() if $self->get_current_version() eq 'none';

    my $brew_dir = $self->{brew_dir};
    $brew_dir =~ s/$ENV{'HOME'}/\$HOME/;
    print "Installed nodebrew in $brew_dir\n\n";
    print "========================================\n";
    print "Export a path to nodebrew:\n\n";
    print "export PATH=$brew_dir/current/bin:\$PATH\n";
    print "========================================\n";
}

sub _cmd_setup_dirs {
    my $self = shift;

    mkdir $self->{brew_dir} unless -e $self->{brew_dir};
    mkdir $self->{src_dir} unless -e $self->{src_dir};
    mkdir $self->{node_dir} unless -e $self->{node_dir};
    mkdir $self->{iojs_dir} unless -e $self->{iojs_dir};
    mkdir $self->{default_dir} unless -e $self->{default_dir};
    mkdir "$self->{default_dir}/bin" unless -e "$self->{default_dir}/bin";
}

sub _cmd_clean {
    my ($self, $args) = @_;

    my $version = Nodebrew::Utils::normalize_version($args->[0]);

    $self->clean($version);
    print "Cleaned $version\n";
}

sub _cmd_selfupdate {
    my ($self, $args) = @_;

    $self->fetch_nodebrew();
    print "Updated successfully\n";
}

sub _cmd_migrate_package {
    my ($self, $args) = @_;

    my $current_version = $self->get_current_version();
    my $is_iojs = $current_version =~ s/^io@//;
    error_and_exit("version not selected") if $current_version eq 'none';

    my $current_type = $is_iojs ? 'iojs' : 'node';
    my @current_packages = $self->get_packages($current_version, $current_type);

    my $version = $self->find_available_version($args->[0]);
    my @target_packages = $self->get_packages($version);
    my $package_dir = Nodebrew::Utils::get_install_dir() . "/$version/lib/node_modules";

    my (@success, @fail);
    foreach my $package_name (@target_packages) {
        if (grep { $_ eq $package_name } @current_packages) {
            print "$package_name is already installed\n";
            next;
        }

        print "Try to install $package_name ...\n";
        my $result = system qq[npm install -g $package_dir/$package_name];
        if ($result) {
            push @fail, $package_name;
        }
        else {
            push @success, $package_name;
        }
    }

    if (@success) {
        print "\nInstalled successfully:\n", join( "\n", @success ), "\n\n";
    }
    if (@fail) {
        print "\nFailed installation:\n", join( "\n", @fail ), "\n\n";
    }
}

sub _cmd_exec {
    my ($self, $args) = @_;

    my $version = $self->find_available_version(shift @$args);

    $ENV{PATH} = Nodebrew::Utils::get_install_dir() . "/$version/bin:$ENV{PATH}";

    shift @$args if $args->[0] eq '--';
    my $command = join ' ', @$args;

    system $command;
    exit $? >> 8;
}

sub _cmd_help {
    my ($self, $args) = @_;

    print <<"...";
nodebrew $VERSION

Usage:
    nodebrew help                         Show this message
    nodebrew install <version>            Download and install <version> (compile from source)
    nodebrew install-binary <version>     Download and install <version> (binary file)
    nodebrew uninstall <version>          Uninstall <version>
    nodebrew use <version>                Use <version>
    nodebrew list                         List installed versions
    nodebrew ls                           Alias for `list`
    nodebrew ls-remote                    List remote versions
    nodebrew ls-all                       List remote and installed versions
    nodebrew alias <key> <value>          Set alias
    nodebrew unalias <key>                Remove alias
    nodebrew clean <version> | all        Remove source file
    nodebrew selfupdate                   Update nodebrew
    nodebrew migrate-package <version>    Install global NPM packages contained in <version> to current version
    nodebrew exec <version> -- <command>  Execute <command> using specified <version>

Example:
    # install from binary
    nodebrew install-binary v0.10.22

    # use a specific version number
    nodebrew use v0.10.22

    # io.js
    nodebrew install-binary io\@v1.0.0
    nodebrew use io\@v1.0.0
...
}

sub get_nightly {
    my ($self, $version) = @_;

    my $type = $self->get_type();
    my $url = $self->get_remote_list_url($type, $version);
    my $html = $self->{fetcher}->fetch($url);
    my $latest;
    while ($html =~ m/(v\d+\.\d+\.\d+-$version.*)\/"/g) {
      $latest = $1;
    }
    return ($latest, $version);
}

sub find_install_version {
    my ($self, $v) = @_;

    my $version = Nodebrew::Utils::normalize_version($v);
    my $release;

    if ($version eq 'nightly' || $version eq 'next-nightly') {
        ($version, $release) = $self->get_nightly($version);
    } elsif ($version !~ m/v\d+\.\d+\.\d+/) {
        ($version, $release) = Nodebrew::Utils::find_version(
            $version, $self->get_remote_version(undef, $version)
        );
    }

    error_and_exit('version not found') unless $version;
    error_and_exit("$version is already installed")
        if -e Nodebrew::Utils::get_install_dir . "/$version";

    return ($version, $release);
}

sub find_available_version {
    my ($self, $arg) = @_;

    my $alias = Nodebrew::Config->new($self->{alias_file});
    my $target_version = Nodebrew::Utils::normalize_version($alias->get($arg) || $arg);
    my $local_version = $self->get_local_version();
    my $version = Nodebrew::Utils::find_version($target_version, $local_version)
        or error_and_exit("$target_version is not installed");

    return $version;
}

sub get_tarball {
    my ($self, $tarballs, $version, $vars) = @_;

    my $tarball;
    my $msg = '';

    $vars ||= {};
    $vars->{version} = $version;
    $vars->{release} ||= "release";

    for (@$tarballs) {
        my $url = Nodebrew::Utils::apply_vars($_, $vars);
        if ($self->{fetcher}->fetch_able($url)) {
            $tarball = $url;
            last;
        }
        else {
            $msg .= "\nCan not fetch: $url";
        }
    }

    error_and_exit("$version is not found\n$msg") unless $tarball;

    return $tarball;
}

sub clean {
    my ($self, $version) = @_;

    if ($version eq 'all') {
        opendir my $dh, $self->{src_dir} or return;
        while (my $file = readdir $dh) {
            next if $file =~ m/^\./;
            my $path = "$self->{src_dir}/$file";
            unlink $path if -f $path;
            rmtree $path if -d $path;
        }
    }
    elsif (-d "$self->{src_dir}/$version") {
        rmtree "$self->{src_dir}/$version";
    }
}

sub is_iojs {
    my $self = shift;

    return $self->{iojs};
}

sub is_node {
    my $self = shift;

    return !$self->{iojs};
}

sub get_type {
    my $self = shift;

    return $self->is_iojs ? 'iojs' : 'node';
}

sub use_default {
    my $self = shift;

    unlink $self->{current} if -l $self->{current};
    symlink $self->{default_dir}, $self->{current};
}

sub get_current_version {
    my $self = shift;

    return 'none' unless -l $self->{current};
    my $current_version = readlink $self->{current};

    return $1 if $current_version =~ m!^$self->{node_dir}/(.+)!;
    return "io\@$1" if $current_version =~ m!^$self->{iojs_dir}/(.+)!;
    return 'none';
}

sub fetch_nodebrew {
    my $self = shift;

    print "Fetching nodebrew...\n";
    my $nodebrew_source = $self->{fetcher}->fetch($self->{nodebrew_url});
    my $bash_completion = $self->{fetcher}->fetch($self->{bash_completion_url});
    my $zsh_completion = $self->{fetcher}->fetch($self->{zsh_completion_url});
    my $fish_completion = $self->{fetcher}->fetch($self->{fish_completion_url});
    my $nodebrew_path = "$self->{brew_dir}/nodebrew";
    my $bash_completion_path = $self->{bash_completion_dir} . '/' . basename($self->{bash_completion_url});
    my $zsh_completion_path = $self->{zsh_completion_dir} . '/' . basename($self->{zsh_completion_url});
    my $fish_completion_path = $self->{fish_completion_dir} . '/' . basename($self->{fish_completion_url});

    mkpath $self->{bash_completion_dir} unless -e $self->{bash_completion_dir};
    mkpath $self->{zsh_completion_dir} unless -e $self->{zsh_completion_dir};
    mkpath $self->{fish_completion_dir} unless -e $self->{fish_completion_dir};

    $self->make_file($nodebrew_source, $nodebrew_path);
    $self->make_file($bash_completion, $bash_completion_path);
    $self->make_file($zsh_completion, $zsh_completion_path);
    $self->make_file($fish_completion, $fish_completion_path);
}

sub make_file {
    my ($self, $content, $dest) = @_;
    open my $fh, '>', $dest or die "Error: $!";
    print $fh $content;
}

sub get_local_version {
    my ($self, $type) = @_;

    my @versions;
    opendir my $dh, Nodebrew::Utils::get_install_dir($type) or die $!;
    while (my $dir = readdir $dh) {
        push @versions, $dir unless $dir =~ '^\.\.?$';
    }

    return \@versions;
}

sub get_remote_list_url {
    my ($self, $type, $release) = @_;

    my $url = $self->{remote_list_url}->{$type || $self->get_type};
    $release ||= 'release';
    my $opt = +{ 'release' => $release };
    if ($release eq 'nightly' || $release eq 'next-nightly') {
      $opt = +{ 'release' => $release };
    }
    return Nodebrew::Utils::apply_vars($url, $opt);
}

sub get_tarballs_url {
    my $self = shift;

    return $self->{tarballs}->{$self->get_type}
}

sub get_tarballs_binary_url {
    my $self = shift;

    return $self->{tarballs_binary}->{$self->get_type}
}



sub get_remote_version {
    my ($self, $type, $version) = @_;

    my $url = $self->get_remote_list_url($type, $version);
    my $html = $self->{fetcher}->fetch($url);
    my @versions;
    my %tmp;
    while ($html =~ m/(\d+\.\d+\.\d+)/g) {
        my $v = "v$1";
        push @versions, $v unless $tmp{$v}++;
    }

    return \@versions;
}

sub get_packages {
    my ($self, $version, $type) = @_;

    my $install_dir = Nodebrew::Utils::get_install_dir($type);
    my $module_dir = "$install_dir/$version/lib/node_modules";
    my @packages;

    opendir my $dh, $module_dir or die $!;
    while (my $dir = readdir $dh) {
        push @packages, $dir unless $dir =~ /^\./;
    }

    return @packages;
}

sub error_and_exit {
    my $msg = shift;

    print "$msg\n";
    exit 1;
}

1;
