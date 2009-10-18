#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use ok 'TehSlow::Event';
use ok 'TehSlow::Sample';
use ok 'TehSlow::JSON';
use ok 'TehSlow::Match';
use ok 'TehSlow::Aggregate::Rate';

my @data = (
    { time => 5, event => "tehslow.start", created  => "blah" },
    { time => 6, event => "tehslow.end",   resource => "blah" },
);

my $j = TehSlow::JSON->new;

my @events = map { $j->unpack($_) } @data;

is( @events, 2, "two events" );

isa_ok( $_, "TehSlow::Event" ) for @events;

my ( $x, $y ) = @events;

is( $x->time, 5, "time" );
is( $y->time, 6, "time" );
is( $y->delta($x), 1, "delta" );

is( $x->event, "tehslow.start", "event" );
is( $x->type, "tehslow.start", "type" );
is( $x->category, "tehslow", "category" );
is( $x->name, "start", "name" );

{
    my $m = TehSlow::Match->new(
        category => "tehslow",
    );

    is_deeply(
        [ $m->filter(@events) ],
        \@events,
        "filter by category",
    );
}

{
    my $m = TehSlow::Match->new(
        name => "start",
    );

    is_deeply(
        [ $m->filter(@events) ],
        [ $x ],
        "filter by name",
    );
}

{
    my $m = TehSlow::Match->new(
        type => "tehslow.end",
    );

    is_deeply(
        [ $m->filter(@events) ],
        [ $y ],
        "filter by type",
    );
}

{
    my $m = TehSlow::Match->new(
        events => 0,
    );

    is_deeply(
        [ $m->filter(@events) ],
        [ ],
        "filter events",
    );
}

{
    my $rate = TehSlow::Aggregate::Rate->new(
        match => TehSlow::Match->new( samples => 0 ),
        sample_params => {
            sample => "events per second",
        },
        interval => 1,
    );

    my @filtered = ($rate->filter(@events), $rate->finish);

    is_deeply(
        \@filtered,
        [
            TehSlow::Sample->new(
                sample => "events per second",
                time => 6,
                data => {
                    count => 2,
                    window => 1,
                },
            ),
        ],
    );
}

done_testing;

# ex: set sw=4 et:

