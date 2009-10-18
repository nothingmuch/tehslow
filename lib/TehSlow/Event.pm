package TehSlow::Event;
use Moose;

use MooseX::Types::Moose qw(Str);

use namespace::clean -except => 'meta';

with qw(TehSlow::Datum);

sub is_event { 1 }
sub is_sample { 0 }

has event => (
    isa => Str,
    is  => "ro",
    required => 1,
);

sub type { shift->event }

has created => (
    isa => Str,
    is  => "ro",
);

sub TO_JSON {
    my $self = shift;

    return {
        event => $self->event,
        time  => $self->time,
        map {
            my $value = $self->$_;
            defined($value) ? ( $_ => $value ) : ();
        } qw(resource created data),
    }
}

__PACKAGE__->meta->make_immutable;

# ex: set sw=4 et:

__PACKAGE__

__END__
