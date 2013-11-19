package CLI;

use FindBin;

use strict;
use warnings;
use Test::More;
use Capture::Tiny ':all';

sub new {
    bless { app => $FindBin::Bin . ($_[1] // '/bin/00-synopsis.pl') }, $_[0];
}

sub execute {
    my ($self, %config) = @_;
    my $app = $self->{app};
    my %result;

    @result{qw(stdout stderr exit)} = map { chomp; $_ } capture {
        my @inc = map { -I => $_ } @INC;
        system 'perl', @inc, $self->{app}, (
            $config{input} ? @{$config{input}} : ()
        );
    };

    if ($config{output}) {
        like $result{$config{output}{channel}},
            $config{output}{contains}, $config{output}{message}
                if $config{output}{channel} && $config{output}{contains};

        warn $result{stderr} if $result{stderr};
    }

    return \%result;
}

1;
