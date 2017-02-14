package Nodebrew::Config;
use strict;
use warnings;

sub new {
    my ($class, $file) = @_;

    my $data = {};
    if (-e $file) {
        open my $fh, '<', $file or die "Error: $!";
        my $str = do { local $/; <$fh> };
        close $fh;
        $data = Nodebrew::Config::_parse($str);
    }

    bless { file => $file, data => $data }, $class;
}

sub get_all {
    my $self = shift;

    return $self->{data};
}

sub get {
    my ($self, $key) = @_;

    return $self->{data}->{$key};
}

sub set {
    my ($self, $key, $val) = @_;

    if ($key && $val) {
        $self->{data}->{$key} = $val;
        return 1;
    }

    return;
}

sub del {
    my ($self, $key) = @_;

    if ($key && $self->get($key)) {
        delete $self->{data}->{$key};
        return 1;
    }
    return;
}

sub save {
    my $self = shift;

    open my $fh, '>', $self->{file} or die "Error: $!";
    print $fh Nodebrew::Config::_strigify($self->{data});
    close $fh;

    return 1;
}

sub _parse {
    my $str = shift;

    my %ret;
    for (split /\n/, $str) {
        my ($key, $val) = ($_ =~ m/^\s*(.*?)\s*=\s*(.*?)\s*$/);
        $ret{$key} = $val if $key;
    }
    return \%ret;
}

sub _strigify {
    my $datas = shift;

    my $ret = '';
    for (keys %$datas) {
        $ret .= $_ . ' = ' . $datas->{$_} . "\n";
    }

    return $ret;
}

1;
