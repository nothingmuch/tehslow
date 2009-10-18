package TehSlow::Aggregate::Rate;
use Moose;

use Carp;

use MooseX::Types::Moose qw(HashRef Bool Num);

use namespace::clean -except => 'meta';

with qw(TehSlow::Filter::Match);

has sample_params => (
    isa => HashRef,
    is  => "ro",
    required => 1,
);

has interval => (
    isa => Num,
    is  => "ro",
);

has sample_at_end => (
    isa => Bool,
    is  => "ro",
    default => 1,
);

has [qw(_next_sample _last_sample _last_event)] => (
    is => "rw",
);

has _count => (
    is => "ro",
    default => sub { my $x; \$x },
);

sub BUILD {
    my $self = shift;

    confess "Match should only apply to events"
        if !$self->match->events or $self->match->samples;
}

sub filter {
    my ( $self, @data ) = @_;

    my $match = $self->match->compiled;

    map { $_->$match ? $self->count($_) : $_->return($_) } @data;
}

sub count {
    my ( $self, $datum ) = @_;

    my $t = $datum->time;

    $self->_last_event($t);

    my $next = $self->_next_sample;

    no warnings 'uninitialized';

    my $ret;

    if ( $next < $t ) {
        $self->_next_sample( $t + $self->interval );
        my $prev = $self->_last_sample;
        $self->_last_sample($t);
        $ret = $self->new_sample( time => $t, prev => $prev );
    }

    ${ $self->_count }++;

    $ret || ();
}

sub return {
    my ( $self, $datum ) = @_;

    my $t = $datum->time;

    $self->_last_event($t);

    my $next = $self->_next_sample;

    no warnings 'uninitialized';

    if ( $next < $t ) {
        $self->_next_sample( $t + $self->interval );
        my $prev = $self->_last_sample;
        $self->_last_sample($t);
        return ( $datum, $self->new_sample( time => $t, prev => $prev ) );
    } else {
        return $datum;
    }
}

sub finish {
    my $self = shift;

    return unless $self->sample_at_end;

    my $t = $self->_last_event;

    if ( $t and ( my $last = $self->_last_sample ) < $t || ${ $self->_count }) {
        return $self->new_sample( time => $t, prev => $last );
    } else {
        return;
    }
}

sub new_sample {
    my ( $self, @args ) = @_;

    my $count = $self->_count;

    my $v = $$count;

    ${ $count } = 0;

    if ( defined $v ) {
        return TehSlow::Sample->new(
            $self->process_sample_params( @args, count => $v ),
        );
    } else {
        # first invocation, just reset the counters, omit a sample of 0
        return;
    }
}

sub process_sample_params {
    my ( $self, @args ) = @_;

    my %args = ( %{ $self->sample_params }, @args );

    my ( $type, $t, $prev ) = delete @args{qw(sample time prev)};

    return (
        sample => $type,
        time => $t,
        data => {
            %args,
            window => $t - $prev,
        },
    );
}

__PACKAGE__->meta->make_immutable;

# ex: set sw=4 et:

__PACKAGE__

__END__
