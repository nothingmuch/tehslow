package TehSlow::Filter::Simple;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(TehSlow::Filter::Match);

requires qw(filter_match);

sub filter {
    my ( $self, @data ) = @_;

    my $match = $self->match->compiled;

    return map { $_->$match ? $self->filter_match($_) : $_ } @data;
}

sub finish { }

# ex: set sw=4 et:

__PACKAGE__

__END__
