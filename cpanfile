requires "Docopt" => "0.03";
requires "Smart::Options" => "0.053";
requires "Validation::Class" => "7.900052";
requires "perl" => "5.010";

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};
