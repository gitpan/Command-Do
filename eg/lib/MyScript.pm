package MyScript;

use Command::Do;

fld 'name' => {
    
    required => 1,
    alias    => 'n',
    optspec  => 's'
    
};

mth 'makeit' => {
    input => ['name'],
    using => sub {
        
        my ($self) = @_;
        
        die "You made it!!!!!!!!!!!!!!!!!" ;
        
    }
};

1;