BEGIN {
    use FindBin;
    use lib $FindBin::Bin . '/lib';
}

use Test::More;
use Test::Command;
use Test::Command::Class::Synopsis;

my $command = Test::Command->new(
    class => Test::Command::Class::Synopsis->new
);

$command->execute(
    output => {
        contains => qr/you sunk my battleship/i,
        message  => 'you sunk my battleship'
    }
);

$command->execute(
    input  => [],
    output => {
        contains => qr/you sunk my battleship/i,
        message  => 'you sunk my battleship'
    }
);

$command->execute(
    input  => ['--vessel', 'sailboat'],
    output => {
        contains => qr/you sunk my sailboat/i,
        message  => 'you sunk my sailboat'
    }
);

$command->execute(
    input  => ['--vessel', 'submarine'],
    output => {
        contains => qr/you sunk my submarine/i,
        message  => 'you sunk my submarine'
    }
);

$command->execute(
    input  => ['--vessel', 'submarine', '--vesion'],
    output => {
        contains => qr/you sunk my submarine/i,
        message  => 'you sunk my submarine'
    }
);

done_testing;
