package Test::Command::Class::SynopsisPlus;

use Command::Do;

field name => {
    required  => 1,
    filters   => ['trim', 'strip', 'titlecase'],
    min_alpha => 4,
};

field x => {
    filters => ['trim', 'strip', 'numeric'],
    default => 0
};

field y => {
    filters => ['trim', 'strip', 'numeric'],
    default => 0
};

command new => sub {
    my ($self, $opts, $args) = @_;
    $self->validate('name') or $self->render_errors;
    # create new ship
};

command move => sub {
    my ($self, $opts, $args) = @_;
    $self->validate('name', 'y', 'x') or $self->render_errors;
    # move ship to different coordinates
    # e.g. using $opts->{speed} which defaults to 10
};

command shoot => sub {
    my ($self, $opts, $args) = @_;
    $self->validate('name', 'x', 'y') or $self->render_errors;
    # fire projectiles from ship
};

sub render_errors {
    my ($self) = @_;
    return $self->errors_to_string;
}

1;

__DATA__

Battleship Script.

Usage:
    yourcmd new <name>
    yourcmd move <name> <x> <y> [--speed=<kn>]
    yourcmd shoot <name> <x> <y>

Options:
    --speed=<kn>  Speed in knots [default: 10].

in yourcmd:

use YourCmd;
YourCmd->new->execute;
