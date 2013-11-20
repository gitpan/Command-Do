# ABSTRACT: Command-Line Applications Made Simple

package Command::Do;

use utf8;
use Validation::Class;
use Validation::Class::Exporter;
use Smart::Options;
use Docopt;
use Carp 'croak';
use Scalar::Util 'blessed';

our $VERSION = '0.120009'; # VERSION

Validation::Class::Exporter->apply_spec(
    settings => ['base' => ['Command::Do']],
    routines => ['command', 'execute', 'usages']
);



sub command {
    my ($code, $name) = (pop, pop);

    croak "Bad arguments to the command method" unless
        'CODE' eq ref $code && ! ref $name;

    $name //= 'default';

    caller->prototype->configuration->builders->add(sub{
        my ($self) = @_;

        croak "Error creating command $name: that command already exists"
            if defined $self->stash("command.commands.$name");

        $self->stash("command.commands.$name" => $code);
    });

    return;
}


sub execute {
    my ($self, @args) = @_;

    $self = caller->new unless blessed $self;
    $self->stash('command.options' => Smart::Options->new);

    my $usage = $self->stash('command.usages');
    unless ($usage) {
        my $pkg = ref $self;
        my $dat = do { no strict 'refs'; \*{"$pkg\::DATA"} };
        unless (eof $dat) {
            binmode $dat, ':raw';
            $usage = join '', (<$dat>);
            $self->stash('command.usages' => $usage);
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

    # execute sub-command (if applicable)
    if (defined $arguments->[0]) {
        my $command = $arguments->[0];
        my $code    = $self->stash("command.commands.$command");

        return $code->($self, $options, $arguments)
            if 'CODE' eq ref $code;
    }

    # execute default command (if applicable)
    my $code = $self->stash("command.commands.default");
    return $code->($self, $options, $arguments, $usage)
        if 'CODE' eq ref $code;

    return;
}


sub usages {
    my $text = pop;

    croak "Bad arguments to the usages method" unless defined $text;

    caller->prototype->configuration->builders->add(sub{
        my ($self) = @_;
        $self->stash('command.usages' => $text);
    });

    return;
}

1;

__END__

=pod

=head1 NAME

Command::Do - Command-Line Applications Made Simple

=head1 VERSION

version 0.120009

=head1 SYNOPSIS

A simple script with option and argument parsing.

    use Command::Do;

    # default command (execute runs on-load)
    execute command sub {
        my ($self, $opts, $args) = @_;
        printf "You sunk my %s\n", $opts->{vessel} || 'Battleship';
    };

    # example usage
    $ ./yourcmd

A simple script with option/argument parsing and input validation.

    use Command::Do;

    field vessel => {
        required => 1,
        filters  => ['trim','strip','titlecase'],
        default  => 'Battleship'
    };

    # default command (execute runs on-load)
    execute command sub {
        my ($self, $opts, $args) = @_;
        printf "You sunk my %s\n", $self->vessel;
    };

    # example usage
    $ ./yourcmd --vessel Yacht

A simple script with option/argument parsing, input validation, and sub-commands.

    use Command::Do;

    field vessel => {
        required => 1,
        filters  => ['trim','strip','titlecase'],
        default  => 'Battleship'
    };

    command move => sub {
        my ($self, $opts, $args) = @_;
        printf "Relocating your %s\n", $self->vessel;
    };

    command engage => sub {
        my ($self, $opts, $args) = @_;
        printf "Your %s has engaged enemy aircrafts\n", $self->vessel;
    };

    # default command (execute runs on-load)
    execute command sub {
        my ($self, $opts, $args) = @_;
        printf "You sunk my %s\n", $self->vessel;
    };

    # example usage
    $ ./yourcmd engage
    $ ./yourcmd move --vessel 'Cruise Ship'
    $ ./yourcmd --vessel=Battleship

A simple script with option/argument parsing, validation, sub-commands and
documentation. Let your documentation determine which options and arguments your
program expects.

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
        $self->validate('name')
            or $self->render_errors;

        # create new ship
    };

    command evade => sub {
        my ($self, $opts, $args) = @_;
        $self->validate('name', 'y_axis', 'x_axis')
            or $self->render_errors;

        # move ship to different coordinates
        # e.g. using $opts->{speed} which defaults to 10
    };

    command submerge => sub {
        my ($self, $opts, $args) = @_;
        $self->validate('name', 'x_axis', 'y_axis')
            or $self->render_errors;

        # cause ship to be under water
    };

    # roll your own output rendering
    sub render_errors {
        my ($self) = @_;
        print STDERR $self->errors_to_string, "\n";
        exit(1);
    }

    1;

    # The DATA section will be render to STDOUT automatically unless the default
    # command or a sub-command matched the execution

    __DATA__

    Battleship Script.

    Usage:
        yourcmd new <name>
        yourcmd evade <name> <x_axis> <y_axis> [--speed=<kn>]
        yourcmd submerge <name> <x_axis> <y_axis>

    Options:
        --speed=<kn>  Speed in knots [default: 10].

As depicted, you can opt in or out of most all features. Please see
L<Validation::Class> for more information on creating field definitions for
validation, and see L<Docopt> for more information on the usage-text format and
parser specification.

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
command and do something! Leave the parsing, routing, validating, exception
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

    # sub-command to be execute when <name> matches the first argument
    command name => sub {
        my ($self, $options, $arguments) = @_;
        ...
    };

    # default command to be execute unless a sub-command matches the request
    # the default command is passed an additional argument, the usages-text
    # which can be print to the console
    command name => sub {
        my ($self, $options, $arguments, $usages_text) = @_;
        ...
    };

=head2 execute

The execute function/method is used to process the command-line request by
parsing the options and arguments and finding a matching pattern, action and/or
routine and executing it. The execute method can take a list of arguments but
defaults to using @ARGV. This method can also be used as a function to initiate
the parsing and execution process from within a script.

    # instantiate and execute from anywhere, using execute as a function
    # will cause the code to execute whenever/wherever loaded
    my $self = YourCmd->new;
    $self->execute;

=head2 usages

The usages function/method is used to register the L<Docopt> compatible
command-line interface specification. This specification will be parsed for
instructions, e.g. default-values, constraints, execution patterns, options and
more.

    usages q{
    yourcmd. does stuff.

    Usage:
        run         causes the console to run
        jump        causes the console to jump
        play        causes the console to play

    Options:
        -h --hours  [default: 8]
    };

If the usages text is not registered using this function, Command::Do will
examine the DATA section for instructions.

    __DATA__
    yourcmd. does stuff.

    Usage:
        run         causes the console to run
        jump        causes the console to jump
        play        causes the console to play

    Options:
        -h --hours  [default: 8]

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
