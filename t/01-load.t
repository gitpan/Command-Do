use Test::More;
use Command::Do;

ok + main->can('command'),   'command command exported';
ok + main->can('execute'),   'command execute exported';
ok + main->can('prototype'), 'class prototype installed';
ok + main->can('usages'),     'command usages exported';

eval { command() };
like $@, qr/bad arguments/i, 'command function w/0 args failed';
eval { command(1) };
like $@, qr/bad arguments/i, 'command function w/1 arg (1) failed';
eval { command(1,1) };
like $@, qr/bad arguments/i, 'command function w/2 args (1,1) failed';
eval { usages() };
like $@, qr/bad arguments/i, 'usages function w/0 args failed';
eval { usages('foobar') };
ok !$@, 'usages function w/0 args returns without failure';
eval { execute() };
ok !$@, 'execute function w/0 args returns without failure';

command test1 => sub {
    return 'test1 ok'
};

command test2 => sub {
    return 'test2 ok'
};

execute command sub {
    return 'default ok'
};

is 'CODE', ref main->stash('command.commands.default'),
    'default command was registered';
is 'CODE', ref main->stash('command.commands.test1'),
    'test1 sub-command was registered';
is 'CODE', ref main->stash('command.commands.test2'),
    'test2 sub-command was registered';

isa_ok 'Validation::Class::Prototype' => ref main->prototype;
isa_ok 'Smart::Options' => ref main->stash('command.options');

done_testing;
