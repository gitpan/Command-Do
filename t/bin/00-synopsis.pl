#!/usr/bin/env perl

BEGIN {
    use FindBin;
    use lib $FindBin::Bin . '/../lib';
}

use Command::Do;

execute command sub {
    my ($self, $opts, $args) = @_;
    printf "You sunk my %s\n", $opts->{vessel} || 'Battleship';
};
