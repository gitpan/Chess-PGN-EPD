# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
use Chess::PGN::EPD;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my @epd;
my @moves;

while (<DATA>) {
    chomp;
    push(@moves,split(/\s+/,$_));
}

@epd = reverse epdlist( @moves );

ok(ECO(\@epd),'C00');
ok(NIC(\@epd),'FR 1');
ok(Opening(\@epd),'French: Labourdonnais variation');

sub ECO {
    my $movesref = shift;

    return epdcode('ECO',$movesref);
}

sub NIC {
    my $movesref = shift;

    return epdcode('NIC',$movesref);
}

sub Opening {
    my $movesref = shift;

    return epdcode('Opening',$movesref);
}

__DATA__
e4 e6 f4 d5 e5 c5 Nf3 Nc6 d3 Be7 Be2 Nh6 c3 O-O O-O f6
exf6 Bxf6 d4 cxd4 cxd4 Qb6 Nc3 Bxd4+ Kh1 Bxc3 bxc3 Ng4
Nd4 Nxd4 cxd4 Nf6 Ba3 Rf7 Rb1 Qd8 Bd3 Bd7 Qf3 Bc6
f5 Ne4 Bxe4 dxe4 Qd1 exf5 Rb2 Qd5 Rbf2 e3 Re2 Bb5
