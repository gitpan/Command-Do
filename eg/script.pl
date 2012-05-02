#!/usr/bin/perl

BEGIN {

    use FindBin;
    use lib $FindBin::Bin . "/lib";
    use lib $FindBin::Bin . "/../lib";

}

use MyScript;

my $script = MyScript->new;

$script->makeit;

