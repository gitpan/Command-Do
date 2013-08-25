# ABSTRACT: Simple Command-Line Interfaces

package Command::Do;

use Validation::Class;
use Validation::Class::Exporter;
use Smart::Options;

our $VERSION = '0.120002'; # VERSION

Validation::Class::Exporter->apply_spec(
    settings => ['base' => ['Command::Do']],
    routines => ['command', 'execute']
);


sub command {
    my ($name, $code) = ! $_[1] ? ('default', $_[0]) : (@_);
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

version 0.120002

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
        print "usage: $0 compliment --name=NAME\n";
    };

in yourcmd:

    use YourCmd;
    YourCmd->new->run;

and, finally, on the command line:

    $ yourcmd
    You sure have a nice name, Gorgeous

    $ yourcmd compliment
    You sure have a nice name, Gorgeous

    $ yourcmd compliment --name=handsome
    You sure have a nice name, Handsome

    $ yourcmd compliment -n=beautiful
    You sure have a nice name, Beautiful

=head1 DESCRIPTION

Command::Do is a simple toolkit for building simple yet sophisticated
command-line applications. It includes very little magic (this is a feature,
not a bug), runs quickly, and is useful when creating, validating, executing,
and organizing command-line applications and actions. Command::Do inherits its
functionality from L<Validation::Class> which makes it and any namespace
derived from it a Validation::Class, which allows you to focus-on and describe
your command-line arguments and how they should be validated. Command::Do also
uses L<Smart::Options> for parsing command-line options.

Command::Do is very unassumming as thus flexible. It does not impose a
particular application configuration and its dependencies are trivial and
easily fatpacked. Command::Do does not render usage-text or auto-validate
arguments, it simply provides you with the tools to do so wrapped-up in a
nice DSL.

The name Command::Do is meant to convey the idea, command-and-do, i.e., write
a command and do something! It is also a play on the word commando which is
defined as a soldier specially trained to carry out raids; In English, the
term commando usually means a person in an elite light infantry and/or special
operations unit, specializing in amphibious landings, parachuting, rappelling
and similar techniques, to conduct and effect attacks ... which is how I like
to think about the command-line scripts I author.

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
