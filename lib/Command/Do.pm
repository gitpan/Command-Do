# ABSTRACT: The power of the Sun in the palm of your hand

package Command::Do;
{
  $Command::Do::VERSION = '0.03';
}

use Validation::Class;
use Validation::Class::Exporter;

use Getopt::Long;

use Command::Do::Directives;

our $VERSION = '0.03'; # VERSION
 
Validation::Class::Exporter->apply_spec(
    routines => ['run'],
    settings => [ base => [
            'Command::Do'
        ]
    ]
);

build sub {
    
    my $self = shift;
    
    # build an opt sepc
    my %opt_spec = ();
    
    while (my($name, $opts) = each(%{$self->fields})) {
        
        if (defined $opts->{optspec}) {
            
            my $conf = $name;
            
            $conf .= "!" unless $opts->{optspec};
            
            if ($opts->{alias}) {
                
                $conf = (
                    "ARRAY" eq ref $opts->{alias} ?
                    join "|", @{$opts->{alias}} : "$opts->{alias}"
                ) . "|$conf";
                
            }
            
            $conf .= $opts->{optspec} =~ /^=/ ?
                $opts->{optspec}    :
                "=$opts->{optspec}" ;
            
            $opt_spec{$conf} = \$self->params->{$name};
            
        }
        
    }
    
    GetOptions %opt_spec;
    
    return $self;
    
};

# the optspec directive specifies the Getopt::Long option specification
# for a given field
dir optspec => sub {1}; #noop


1;
__END__
=pod

=head1 NAME

Command::Do - The power of the Sun in the palm of your hand

=head1 VERSION

version 0.03

=head1 SYNOPSIS

in yourcmd:

    use YourCmd;
    YourCmd->run;

in lib/YourCmd.pm

    package YourCmd;
    
    use Command::Do;
    
    field name => {
        required => 1,
        alias    => 'n',
        optspec  => '=s'
    };
    
    method run => {
        
        input => ['name'],
        using => sub {
            
            exit print "You sure have a nice name, " . shift->name;
            
        }
        
    };

and, finally, at the command line:

    $ yourcmd --name "Handsome"
    You sure have a nice name, Handsome

or, ... use one CLI (command-line interface) to rule them all.

    #!/usr/bin/env perl
    
    package Bit;
    
    use Command::Do;
    
    fld command => {
    
        required   => 1,
        min_length => 2,
        filters    => ['trim', 'strip', sub { $_[0] =~ s/\W/\_/g; $_[0] }]
    
    };
    
    mth run => {
    
        input => ['command'],
        using => sub {
        
            my ($self) = @_;
            
            my $class = $self->class($self->command);
            
            if ($class) {
                
                $class->run # run child command class
                
            }
        
        }
    
    };
    
    bld sub {
        
        my ($self) = @_;
        
        $self->command(shift @ARGV); 
        
    };
    
    package main;
    
        Bit->new->run
    
    1;

=head1 DESCRIPTION

Command::Do is an extremely easy method for creating, validating, executing, and
organizing command-line applications. Command::Do inherits most of its
functionality from the ever-awesome L<Validation::Class> and L<Getopt::Long>.

Command::Do is both simple, effective and anti-complicated. It is very
unassumming and flexible. It does not impose a particular application
configuration and its dependencies are trivial.

... sometimes you need an all-in-one command script:

    package yourcmd;
    use Command::Do;
    
    mixin all  => {
        filters => [qw/trim strip/]
    };
    
    field file => {
        mixin   => 'all',
        optspec => 's@', # 100% Getopt::Long Compliant
        alias   => ['f'] # directive is attached to the option spec
    }; 
    
    # self-validating routines
    method run => {
    
        input => ['file'],
        using => sub {
            
            exit print join "\n", @{shift->file};
            
        }
        
    };
    
    yourcmd->run;

... sometimes you need a suite of commands:

    package yourcmd;
    use YourCmd;
    set
    {
        # each command is independent and can invoke sub-classes
        classes => 1, # loads and registers yourcmd::*
        
    };
    
    # happens before new
    build sub {
        
        my $self = shift;
        
        $self->{next_command} = shift @ARGV;
        
        return $self;
        
    };
    
    sub run {
    
        my $self = shift;
        
        my $next_command = $self->{next_command}; # e.g. sub_cmd
        
        # invokes other commands using the class method, see Validation::Class
        my $sub = $self->class($next_command); # load lib/YourCmd/SubCmd.pm
        
        return $sub->run;
        
    };
    
    yourcmd->run;

Please note: Command::Do is very minimalistic and tries to remain unassuming,
each class field (see L<Validation::Class>) that is to be used as a command line
option must have an C<optspec> directive defined. The optspec directive should
be a valid L<Getopt::Long> option specification minus a name and aliases which
are deduced from the field name and alias directive.

    package ...;
    use Command::Do;
    
    field verbose => {
        optspec => '', # sets flag, same as '!'
        alias   => 'v'
    };
    
    # this is the equivalent to the following Getopt::Long statement
    # GetOptions('verbose|v!' => \$variable);

Furthermore, in addition to being a class that represents a command that does
stuff, Command::Do is:

    com-man-do: A soldier specially trained to carry out raids.
    
    In English, the term commando means a specific kind of individual soldier or
    military unit. In contemporary usage, commando usually means elite light
    infantry and/or special operations forces units, specializing in amphibious
    landings, parachuting, rappelling and similar techniques, to conduct and
    effect attacks. (per wikipedia)

... which is how I like to think about the command-line scripts I author.

=head1 AUTHOR

Al Newkirk <awncorp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by awncorp.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

