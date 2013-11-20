package Test::Command;

use strict;
use warnings;
use Test::More;

sub new {
    my ($class, %options) = @_;
    bless \%options, $class;
}

sub execute {
    my ($self, %config) = @_;
    my $class = $self->{class};
    my $data  = $class->execute($config{input} ? @{$config{input}} : ());
    ok $data, 'Data captured';

    my %result;

    if ($config{output}) {
        like $data, $config{output}{contains}, $config{output}{message}
            if $config{output}{contains};

        printf STDERR "Errors: %s\n", $class->errors_to_string
            if $class->error_count;
    }

    return \%result;
}

1;
