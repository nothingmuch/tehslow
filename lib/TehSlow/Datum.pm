package TehSlow::Datum;
use Moose::Role;

use MooseX::Types::Moose qw(Num Str Undef HashRef);

use namespace::clean;

requires qw(TO_JSON type is_event is_sample);

has time => (
    isa => Num,
    is  => "ro",
    required => 1,
);

has resource => (
    isa => Str,
    is  => "ro",
);

has data => (
    isa => HashRef|Str,
    is  => "ro",
);

has [qw(category name)] => (
    isa => Str|Undef,
    is  => "ro",
    lazy_build => 1,
);

sub _build_category {
    my $self = shift;

    if ( $self->type =~ /^([^\.]+)\./ ) {
        return $1;
    } else {
        return undef;
    }
}

sub _build_name {
    my $self = shift;

    if ( $self->type =~ /([^\.]+)$/ ) {
        return $1;
    } else {
        return undef;
    }
}

sub delta {
    my ( $self, $other ) = @_;

    $self->time - $other->time;
}

# ex: set sw=4 et:

__PACKAGE__

__END__
