requires "Docopt" => "0.03";
requires "Exporter::Tiny" => "0.030";
requires "Smart::Options" => "0.053";
requires "Validation::Class" => "7.900054";
requires "perl" => "v5.10.0";

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};
