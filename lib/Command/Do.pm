# ABSTRACT: Simple Command-Line Application Framework

package Command::Do;

use utf8;
use Validation::Class;
use Validation::Class::Exporter;
use Smart::Options;
use Docopt;
use Scalar::Util 'blessed';

our $VERSION = '0.120005'; # VERSION

Validation::Class::Exporter->apply_spec(
    settings => ['base' => ['Command::Do']],
    routines => ['command', 'execute']
);



sub command {
    my ($code, $name) = (pop, pop);

    $name //= 'default';

    caller->prototype->configuration->builders->add(sub{
        my ($self) = @_;

        die "Error creating command $name: that command already exists"
            if defined $self->stash("command.commands.$name");

        $self->stash("command.commands.$name" => $code);
    });

    return;
}


sub execute {
    my ($self, @args) = @_;

    $self //= caller(0)->new;
    $self->stash('command.options' => Smart::Options->new);

    my $usage;
    unless ($self->stash('command.usages')) {
        my $pkg = ref $self;
        my $dat = do { no strict 'refs'; \*{"$pkg\::DATA"} };
        unless (eof $dat) {
            binmode $dat, ':raw';
            $self->stash('command.usages' => ($usage = join '', (<$dat>)));
        }
    }

    my $options   = $self->stash("command.options")->parse(@args);
    my $arguments = delete $options->{'_'} // [];

    my $mappings = eval {
        docopt(doc => $usage, help => 0, version => 0)
    } if $usage;

    if ($mappings) {
        my $selection = {};
        while (my($key, $val) = each %{$mappings}) {
            next unless defined $val;
            $key =~ s/(<|>)//g;
            $key =~ s/^-+//;
            if (ref $val && blessed $val) {
                $selection->{$key} = $val->isa('boolean') ? 0 + $val : $val;
            }
            else {
                $selection->{$key} = $val;
            }
        }
        $mappings = $selection;
    }

    $self->params->add($options);
    $self->params->add($mappings) if $mappings;
    $self->prototype->normalize($self);

    $options = $self->params->hash;

    if (defined $arguments->[0]) {
        my $command = $arguments->[0];
        my $code = $self->stash("command.commands.$command");
        if ('CODE' eq ref $code) {
            return $code->($self, $options, $arguments);
        }
        else {
            print "$usage\n" if $usage;
            exit(0);
        }
    }
    else {
        my $code = $self->stash("command.commands.default");
        if ('CODE' eq ref $code) {
            return $code->($self, $options, $arguments);
        }
        else {
            print "$usage\n" if $usage;
            exit(0);
        }
    }

    return;
}

1;

__END__

=pod

=head1 NAME

Command::Do - Simple Command-Line Application Framework

=head1 VERSION

version 0.120005

=head1 SYNOPSIS

in yourcmd:

    use Command::Do;

    execute command sub {
        my ($self, $opts, $args) = @_;
        printf "You sunk my %s\n", $opts->{vessel} || 'Battleship';
    };

However, there are times when you're not creating one-off/throw-away scripts and
you actually care about maintaining, validating and documenting your command-line
applications. The follow is an example of the power and simplicity of using
Command::Do, please see L<Validation::Class> for more information on creating
field definitions.

in lib/YourCmd.pm

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

and, finally, on the command line:

    $ yourcmd new explorer
    $ yourcmd move explorer 10 10
    $ yourcmd shoot explorer

=head1 DESCRIPTION

Command::Do is a simple toolkit for building simple or sophisticated
command-line applications with ease. It includes very little magic, executes
quickly, and is useful when creating, validating, executing, and organizing
command-line applications and actions. Command::Do inherits most of its
functionality from L<Validation::Class> which allows you to focus on describing
your command-line arguments and how they should be validated. Command::Do also
uses L<Docopt> and L<Smart::Options> for parsing additional command-line options
and arguments. Command::Do is very unassuming as thus flexible. It does not
impose a particular application configuration and its dependencies are trivial
and easily fat-packed. Command::Do simply provides you with the tools to create
simple or sophisticated command-line interfaces, all wrapped-up in a nice DSL.

The name Command::Do is meant to convey the idea, command-and-do, i.e., write a
command and do something! Leave the parsing, routing, validating, exeception
handling and execution to the framework. Command::Do inherits all methods from
L<Validation::Class> and implements the following new ones.

=head1 METHODS

=head2 command

The command function/method is used to register a coderef by name which may be
automatically invoked by the execute method if it's name matches the first
argument to the execute method. The command method can be passed a coderef, or a
name and coderef. The coderef, when executed will be passed an instance of the
current class, a hashref of command-line options, and an arrayref of extra
command-line arguments. If passed a coderef without an associated name, that
routine will be registered as the default routine to be executed by default
if/when no other named routines match.

    command name => sub {
        my ($self, $options, $arguments) = @_;
    };

=head2 execute

The execute function/method is used to process the command-line request by
parsing the options and arguments and finding a matching pattern, action and/or
routine and executing it. The execute method can take a list of arguments but
defaults to using @ARGV. This method can also be used as a function to initiate
the parsing and execution process from within a script.

    my $self = YourCmd->new;
    $self->execute;

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
