# ABSTRACT: The power of the Sun in the palm of your hand

package Command::Do;
{
  $Command::Do::VERSION = '0.01';
}

use Validation::Class;
use Validation::Class::Exporter;

use Getopt::Long;

use Command::Do::Directives;

our $VERSION = '0.01'; # VERSION
 
Validation::Class::Exporter->apply_spec(
    routines => ['run'],
    settings => [ base => [
            'Command::Do', 'Command::Do::Directives'
        ]
    ]
);

bld sub {
    
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


1;
__END__
=pod

=head1 NAME

Command::Do - The power of the Sun in the palm of your hand

=head1 VERSION

version 0.01

=head1 SYNOPSIS

in yourcmd:

    use YourCmd;
    YourCmd->run;

in lib/YourCmd.pm

    package YourCmd;
    
    use Command::Do;
    
    fld name => {
        require => 1,
        alias   => 'n',
        optspec => '=s'
    };
    
    mth run => {
        
        input => ['name'],
        using => sub {
            
            exit print "You sure have a nice name, " . shift->name;
            
        }
        
    };

and, finally, at the command line:

    $ yourcmd --name "Handsome"
    You sure have a nice name, Handsome

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
    
    mxn all  => {
        filters => [qw/trim strip/]
    };
    
    fld file => {
        mixin   => 'all',
        optspec => 's@', # 100% Getopt::Long Compliant
        alias   => ['f'] # directive is attached to the option spec
    }; 
    
    # self-validating routines
    mth run => {
    
        input => ['file'],
        using => sub {
            
            exit print join "\n", @{shift->file};
            
        }
        
    };
    
    yourcmd->run;

... sometimes you need a suite of commands:

    package yourcmd;
    
    use YourCmd;
    set {
        # each command is independent and can invoke sub-classes
        classes => 1,
    };
    
    # happens before new
    bld sub {
        
        my $self = shift;
        
        $self->{next_command} = shift @ARGV;
        
        return $self;
        
    };
    
    sub run {
    
        my $self = shift;
        
        # this command invokes others
        my $next_command = $self->{next_command}; # e.g. sub_cmd
        
        # see Validation::Class
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
    
    fld verbose => {
        optspec => '', # sets flag, same as '!'
        alias   => 'v'
    };
    
    # this is the equivalent to the following Getopt::Long statement
    # GetOptions('verbose|v!' => \$variable);

Furthermore, in addition to being a class that represents a command that does
stuff, Command::Do is:

    com-man-do:
        -- A soldier specially trained to carry out raids.
    
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

