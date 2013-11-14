BEGIN {
    use FindBin;
    use lib $FindBin::Bin . '/lib';
}

use Test::More;
use CLI;

my $cli = CLI->new('/bin/00-synopsis.pl');

$cli->execute(
    output => {
        channel  => 'stdout',
        contains => qr/you sunk my battleship/i,
        message  => 'you sunk my battleship'
    }
);

$cli->execute(
    input  => [],
    output => {
        channel  => 'stdout',
        contains => qr/you sunk my battleship/i,
        message  => 'you sunk my battleship'
    }
);

$cli->execute(
    input  => ['--vessel', 'sailboat'],
    output => {
        channel  => 'stdout',
        contains => qr/you sunk my sailboat/i,
        message  => 'you sunk my sailboat'
    }
);

$cli->execute(
    input  => ['--vessel', 'submarine'],
    output => {
        channel  => 'stdout',
        contains => qr/you sunk my submarine/i,
        message  => 'you sunk my submarine'
    }
);

$cli->execute(
    input  => ['--vessel', 'submarine', '--vesion'],
    output => {
        channel  => 'stdout',
        contains => qr/you sunk my submarine/i,
        message  => 'you sunk my submarine'
    }
);

done_testing;
