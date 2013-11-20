package Test::Command::Class::Synopsis;

use Command::Do;

command sub {
    my ($self, $opts, $args) = @_;
    return sprintf "You sunk my %s\n", $opts->{vessel} || 'Battleship';
};

1;
