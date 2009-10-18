package TehSlow::Match;
use Moose;

use Carp;

use MooseX::Types::Moose qw(Str ArrayRef HashRef RegexpRef CodeRef Undef);

use namespace::clean -except => 'meta';

has events => (
    isa => "Bool",
    is  => "ro",
    default => 1,
);

has samples => (
    isa => "Bool",
    is  => "ro",
    default => 1,
);

has [qw(type name category)] => (
    isa => Str|RegexpRef|ArrayRef|CodeRef,
    is  => "ro",
);

has data => (
    isa => Str|HashRef|ArrayRef|CodeRef,
    is  => "ro",
);

sub filter {
    my ( $self, @args ) = @_;

    my $f = $self->compiled;

    grep { $_->$f } @args;
}

has compiled => (
    isa => CodeRef,
    is  => "ro",
    lazy_build => 1,
);

sub _compile_class_filter {
    my $self = shift;

    if ( $self->events && $self->samples ) {
        return '';
    } elsif ( $self->events ) {
        return 'return unless $_[0]->is_event';
    } elsif ( $self->samples ) {
        return 'return unless $_[0]->is_sample';
    } else {
        return 'return';
    }
}

sub _compile_match {
    my ( $self, $field, $rvalue_exp, $match ) = @_;

    if ( ref $match eq 'CODE' ) {
        return [
            sprintf('return unless (%s)->$match_%s()', $rvalue_exp, $field),
            "\$match_$field" => $match,
        ];
    } elsif ( ref $match eq 'ARRAY' ) {
        my %hash = map { $_ => undef } @$match;
        return [
            sprintf('return unless exists $match_%s->{%s}', $field, $rvalue_exp),
            "\$match_$field" => \%hash,
        ];
    } elsif ( not ref $match ) {
        return sprintf 'return unless %s eq qq{%s}', $rvalue_exp, quotemeta($match);
    } else {
        return sprintf 'return unless %s =~ qr(%s)', $rvalue_exp, qr/$match/;
    }
}

sub _compile_type_filter {
    my $self = shift;

    my @ret_vars;
    my $ret_code = '';

    # these can be merged and optimized

    map {
        my $match = $self->$_;

        $match 
            ? $self->_compile_match($_, '$_[0]->' . $_, $match)
            : ();
    } qw(type category name);
}

sub _compile_data_filter {
    my $self = shift;

    if ( $self->data ) {
        die "TODO";
    } else {
        return;
    }
}

sub _eval {
    my ( $self, $code, $env ) = @_;

    my @vars = map { "my $_ = \$env{$_}" } keys %$env;

    my ( $cv, $error ) = do {
        local $@;
        eval(join ";\n", @vars, "sub { $code }"), $@;
    };

    return ( $cv || die $error );
}

sub _build_compiled {
    my $self = shift;

    my @all_vars;
    my $code = '';

    my @fragments = map { $self->${\ "_compile_${_}_filter" } } qw(class type data);

    foreach my $fragment ( @fragments ) {
        my ( $filter, @vars ) = ref $fragment ? @$fragment : ( $fragment );

        return sub { } if $filter eq 'return'; # unconditional fail

        push @all_vars, @vars;

        $code .= "$filter;\n";
    }

    $code .= 'return 1';

    $self->_eval($code, { @all_vars });
}

__PACKAGE__->meta->make_immutable;

# ex: set sw=4 et:

__PACKAGE__

__END__
