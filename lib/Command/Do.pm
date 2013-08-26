# ABSTRACT: Simple Command-Line Interfaces

package Command::Do;

use Validation::Class;
use Validation::Class::Exporter;
use Smart::Options;

our $VERSION = '0.120003'; # VERSION

Validation::Class::Exporter->apply_spec(
    settings => ['base' => ['Command::Do']],
    routines => ['command', 'execute']
);



sub command {
    my ($name, $code) = (pop, pop);

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

    $self->stash('command.options' => Smart::Options->new);

    my $options   = $self->stash("command.options")->parse(@args);
    my $arguments = delete $options->{'_'} // [];

    $self->params->add($options);
    $self->prototype->normalize($self);

    if (defined $arguments->[0]) {
        my $command = $arguments->[0];
        if (defined $command) {
            my $code = $self->stash("command.commands.$command");
            if (defined $code) {
                if ('CODE' eq ref $code) {
                    return $code->($self, $options, $arguments);
                }
            }
        }
    }
    else {
        my $code = $self->stash("command.commands.default");
        if (defined $code) {
            if ('CODE' eq ref $code) {
                return $code->($self, $options, $arguments);
            }
        }
    }

    return;
}

1;

__END__

=pod

=head1 NAME

Command::Do - Simple Command-Line Interfaces

=head1 VERSION

version 0.120003

=head1 SYNOPSIS

in lib/YourCmd.pm

    package YourCmd;

    use Command::Do;

    field name => {
        alias   => 'n',
        filters => ['trim', 'strip', 'titlecase'],
        default => 'Gorgeous'
    };

    command compliment => sub {
        my ($self, $options, $args) = @_;
        if ($self->validate('name')) {
            printf "You sure have a nice name, %s\n", $self->name;
        }
    };

    command sub {
        my ($self, $options, $args) = @_;
        print "Usage: $0 compliment --name=NAME\n";
    };

in yourcmd:

    use YourCmd;
    YourCmd->new->execute;

and, finally, on the command line:

    $ yourcmd
    Usage: ./yourcmd compliment --name=NAME

    $ yourcmd compliment
    You sure have a nice name, Gorgeous

    $ yourcmd compliment --name=handsome
    You sure have a nice name, Handsome

    $ yourcmd compliment -n=beautiful
    You sure have a nice name, Beautiful

=head1 DESCRIPTION

Command::Do is a simple toolkit for building simple yet sophisticated
command-line applications. It includes very little magic, executes quickly,
and is useful when creating, validating, executing, and organizing command-line
applications and actions. Command::Do inherits most of its functionality from
L<Validation::Class> which allows you to focus on and describe your
command-line arguments and how they should be validated. Command::Do also uses
L<Smart::Options> for parsing command-line options. Command::Do is very
unassumming as thus flexible. It does not impose a particular application
configuration and its dependencies are trivial and easily fatpacked.
Command::Do does not render usage-text or auto-validate arguments, it simply
provides you with the tools to do so wrapped-up in a nice DSL.

The name Command::Do is meant to convey the idea, command-and-do, i.e., write
a command and do something! It is also a play on the word commando which is
defined as a soldier specially trained to carry out raids; In English, the
term commando usually means a person in an elite light infantry and/or special
operations unit, specializing in amphibious landings, parachuting, rappelling
and similar techniques, to conduct and effect attacks ... which is how I like
to think about the command-line scripts I author.

=head1 METHODS

=head2 command

The command method is used to register a coderef by name which may be
automatically invoked by the execute method if it's name matching the first
argument to the execute method. The command method ca be passed a coderef, or a
name and coderef. The coderef, when executed will be passed an instance of the
current class, a hashref of command-line options, and an arrayref of extra
command-line arguments.

    command name => sub {
        my ($self, $options, $arguments) = @_;
    };

=head2 execute

The execute method is used to process the command-line request by parsing the
options and arguments and finding a matching action/routine and executing it.
The execute method can take a list of options/arguments but by default uses
@ARGV.

    my $self = YourCmd->new;
    $self->execute;

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
