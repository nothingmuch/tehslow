package TehSlow::Output;
use Moose::Role;

use MooseX::Types::Moose qw(Object Undef CodeRef FileHandle ArrayRef);

use Scalar::Util qw(weaken);

use Time::HiRes qw(time);

use IO::Handle;

use TehSlow::Event;
use TehSlow::Sample;
use TehSlow::JSON;

use namespace::clean;

has out => (
    isa => Object|Undef|CodeRef|FileHandle|ArrayRef,
    is => "rw",
    default => sub { *STDOUT{IO} },
    trigger => sub { shift->_clear_out_cb },
);

has _out_cb => (
    isa => CodeRef,
    is  => "ro",
    lazy_build => 1,
);

sub _build__out_cb {
    my $self = shift;

    weaken($self);

    my $out = $self->out;

    if ( ref $out eq 'CODE' ) {
        return $out;
    } elsif ( ref $out eq 'ARRAY' ) {
        sub { push @$out, @_ };
    } elsif ( blessed($out) and $out->isa("AnyEvent::Handle") ) {
        return sub { $out->push_write( join "\n", $self->_json->encode(@_), "" ) };
    } elsif ( defined $out ) {
        return sub {
            local $, = local $\ = "\n";
            $out->print($self->_json->encode(@_));
        }
    } else {
        return sub {};
    }
}

has _json => (
    isa => "TehSlow::JSON",
    is  => "ro",
    lazy_build => 1,
);

sub _build__json { TehSlow::JSON->new }

sub output {
    my ( $self, @data ) = @_;

    $self->_out_cb->(@data);

    return;
}


sub event {
    my $self = shift;

    $self->_out_cb->(
        TehSlow::Event->new(
            time => time(),
            event => @_,
        ),
    );

    return;
}

sub sample {
    my $self = shift;
    
    $self->_out_cb->(
        TehSlow::Sample->new(
            time => time(),
            sample => @_,
        ),
    );

    return;
}

# ex: set sw=4 et:

__PACKAGE__

__END__
