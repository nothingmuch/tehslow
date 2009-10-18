package TehSlow::Util;

use strict;
use warnings;

use Time::HiRes qw(time);

use TehSlow::Event;
use TehSlow::Sample;

use TehSlow::JSON;

use namespace::clean;

use Sub::Exporter -setup => {
    exports => [qw(event sample e s out)],
};

my $json;

sub e ($;@) { out(&event(@_)) }
sub s ($;@) { out(&sample(@_)) }

sub out {
    $json ||= TehSlow::JSON->new;
    local $, = local $\ = "\n";
    print $json->encode(@_);
}

sub event ($;@) {
    TehSlow::Event->new(
        time => time(),
        event => @_,
    );
}

sub sample ($;@) {
    TehSlow::Sample->new(
        time => time(),
        sample => @_,
    );
}

# ex: set sw=4 et:

__PACKAGE__

__END__
