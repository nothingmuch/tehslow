package TehSlow::Output;
use Moose::Role;

use MooseX::Types::Moose qw(Object Undef);

use Time::HiRes qw(time);

use IO::Handle;

use TehSlow::Event;
use TehSlow::Sample;
use TehSlow::JSON;

use namespace::clean;

has out => (
    isa => Object|Undef,
    is => "rw",
    default => sub { *STDOUT{IO} },
);

has _json => (
    isa => "TehSlow::JSON",
    is  => "ro",
    lazy_build => 1,
);

sub _build__json { TehSlow::JSON->new }

sub output {
    my ( $self, @data ) = @_;

    my $out = $self->out or return;

    if ( $out->can("events") ) {
        $out->process_events(@data);
    } else {
        my $method = $out->can("print") || $out->can("push_write");

        local $\ = "\n";
        $out->$method($_) for $self->_json->encode(@data);
    }
}

sub event {
    my $self = shift;

    $self->output(
        TehSlow::Event->new(
            time => time(),
            event => @_,
        ),
    );
}

sub sample {
    my $self = shift;
    
    $self->output(
        TehSlow::Sample->new(
            time => time(),
            sample => @_,
        ),
    );
}

# ex: set sw=4 et:

__PACKAGE__

__END__
