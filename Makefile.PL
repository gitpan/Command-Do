
use strict;
use warnings;

use 5.010000;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Command-Line Applications Made Simple",
  "AUTHOR" => "Al Newkirk <anewkirk\@ana.io>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Command-Do",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Command::Do",
  "PREREQ_PM" => {
    "Docopt" => "0.03",
    "Exporter::Tiny" => "0.030",
    "Smart::Options" => "0.053",
    "Validation::Class" => "7.900054"
  },
  "TEST_REQUIRES" => {},
  "VERSION" => "0.120010",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Docopt" => "0.03",
  "Exporter::Tiny" => "0.030",
  "Smart::Options" => "0.053",
  "Validation::Class" => "7.900054"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



