package MyScript;

use Command::Do 'fld', 'mth';

fld 'name' => {

    required => 1,
    alias    => 'n',
    optspec  => 's',
    filters  => [qw/trim strip titlecase/]

};

mth 'makeit' => {
    input => ['name'],
    using => sub {

        my ($self) = @_;

        exit print "You made it ", $self->name, " !!!!!!!!!!!!!!!!!\n";

      }
};

1;
