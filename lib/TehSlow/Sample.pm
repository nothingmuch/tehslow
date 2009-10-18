package TehSlow::Sample;
use Moose;

use MooseX::Types::Moose qw(Str);

use namespace::clean -except => 'meta';

with qw(TehSlow::Datum);

sub is_event { 0 }
sub is_sample { 1 }

has sample => (
    isa => Str,
    is  => "ro",
    required => 1,
);

sub type { shift->event }

sub TO_JSON {
    my $self = shift;

    return {
        sample => $self->type,
        time   => $self->time,
        map {
            my $value = $self->$_;
            defined($value) ? ( $_ => $value ) : ();
        } qw(resource data),
    }
}

__PACKAGE__->meta->make_immutable;

# ex: set sw=4 et:

__PACKAGE__

__END__
