#!/usr/bin/perl
# 02_Storable.t -- test 'Storable' DBs.
#
use strict;
use warnings;
use diagnostics;
use Storable qw( retrieve );
use Test::More tests => 3;

is( ECO('rnbqkbnr/ppp2ppp/4p3/3p4/3PP3/3B4/PPP2PPP/RNBQK1NR b KQkq -'), 'C00','ECO.stor lookup' );
is( NIC('r1bqk1nr/pp1pppbp/2n3p1/2p5/2P1P3/2N3P1/PP1P1PBP/R1BQK1NR b KQkq -','NIC.stor lookup'),
    'EO 30' );
is( Opening('r1bqk1nr/pppp1ppp/1bn5/4p3/1PB1P3/5N2/PBPP1PPP/RN1QK2R b KQkq -','Opening.stor lookup'),
    'Evans gambit declined, Cordel variation' );

sub ECO {
    my $epd    = shift;
    my $STORef = retrieve('db/ECO.stor')
      or die "Couldn't open db/ECO.stor";
    $STORef->{$epd};
}

sub NIC {
    my $epd    = shift;
    my $STORef = retrieve('db/NIC.stor')
      or die "Couldn't open db/NIC.stor";
    $STORef->{$epd};
}

sub Opening {
    my $epd    = shift;
    my $STORef = retrieve('db/Opening.stor')
      or die "Couldn't open db/Opening.stor";
    $STORef->{$epd};
}
