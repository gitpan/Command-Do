package Command::Do::Directives;
{
  $Command::Do::Directives::VERSION = '0.01';
}

use Validation::Class;

# the optspec directive specifies the Getopt::Long option specification
# for a given field
dir optspec => sub {1}; #noop

1;