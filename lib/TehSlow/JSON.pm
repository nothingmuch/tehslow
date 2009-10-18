package TehSlow::JSON;
use Moose;

use Carp;

use MooseX::Types::Moose qw(Object);

use JSON;

use namespace::clean -except => 'meta';

has json => (
    isa => Object,
    is  => "ro",
    lazy_build => 1,
);

sub _build_json {
    my $json = JSON->new;

    $json->convert_blessed(1);

    return $json;
}

sub encode {
    my ( $self, @data ) = @_;

    my $json = $self->json;

    if ( @data == 1 ) {
        return $json->encode($data[0]);
    } else {
        return map { $json->encode($_) } @data;
    }
}

sub decode {
    my ( $self, $chunk ) = @_;

    my @data = map { $self->unpack_datum($_) } $self->json->incr_parse($chunk);

    if ( @data == 1 ) {
        return $data[0];
    } else {
        return @data;
    }
}

sub unpack {
    my ( $self, $datum ) = @_;

    if ( ref $datum eq 'HASH' ) {
        if ( exists $datum->{event} ) {
            return TehSlow::Event->new($datum);
        } elsif ( exists $datum->{sample} ) {
            return TehSlow::Sample->new($datum);
        }
    }

    croak "Unknown datum type";
}

__PACKAGE__->meta->make_immutable;

# ex: set sw=4 et:

__PACKAGE__

__END__
