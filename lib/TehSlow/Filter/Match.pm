package TehSlow::Filter::Match;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(TehSlow::Filter);

has match => (
    isa => "TehSlow::Match",
    is  => "ro",
    required => 1,
);

# ex: set sw=4 et:

__PACKAGE__

__END__
