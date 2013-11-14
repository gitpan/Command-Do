#!/usr/bin/env perl

package YourCmd;

use Command::Do;

field name => {
    required  => 1,
    filters   => ['trim', 'strip', 'titlecase'],
    min_alpha => 4,
};

field x_axis => {
    filters => ['trim', 'strip', 'numeric'],
    default => 0
};

field y_axis => {
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
    $self->validate('name', 'y_axis', 'x_axis') or $self->render_errors;
    # move ship to different coordinates
    # e.g. using $opts->{speed} which defaults to 10
};

command shoot => sub {
    my ($self, $opts, $args) = @_;
    $self->validate('name', 'x_axis', 'y_axis') or $self->render_errors;
    # fire projectiles from ship
};

sub render_errors {
    my ($self) = @_;
    print STDERR $self->errors_to_string, "\n";
    exit(1);
}

1;

__DATA__

Battleship Script.

Usage:
    yourcmd new <name>
    yourcmd move <name> <x_axis> <y_axis> [--speed=<kn>]
    yourcmd shoot <name> <x_axis> <y_axis>

Options:
    --speed=<kn>  Speed in knots [default: 10].

in yourcmd:

use YourCmd;
YourCmd->new->execute;
