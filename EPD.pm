package Chess::PGN::EPD;

use 5.006;
use strict;
use warnings;
use Chess::PGN::Moves;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(
	&epdlist
);
our $VERSION = '0.02';

sub epdlist {
    my ( @moves, $debug ) = @_;
    my %board = qw(
      a1 R a2 P a7 p a8 r 
      b1 N b2 P b7 p b8 n 
      c1 B c2 P c7 p c8 b 
      d1 Q d2 P d7 p d8 q 
      e1 K e2 P e7 p e8 k 
      f1 B f2 P f7 p f8 b 
      g1 N g2 P g7 p g8 n 
      h1 R h2 P h7 p h8 r 
    );
    my $w  = 1;
    my $Kc = 1;
    my $Qc = 1;
    my $kc = 1;
    my $qc = 1;
    my @epdlist;
    my $lineno = 1;

    foreach (@moves) {
        if ($_) {
            my ( $piece, $to, $from, $promotion ) = movetype( $w, $_ );
            my $ep = "-";
            my $enpassant;

            print "Move[$lineno]='$_'" if $debug;
            $lineno++ if $debug;
            if ($piece) {
                print ", piece='$piece'" if $debug;
                print ", to='$to'" if $to and $debug;
                print ", from='$from'" if $from and $debug;
                print ", promotion='$promotion'" if $promotion and $debug;
            }
            print "\n" if $debug;

            if ( $piece eq "P" ) {
                $piece     = "p" if not $w;
                $promotion = lc($promotion) if $promotion and not $w;
                if ($from) {
                    $from .= substr( $to, 1, 1 );
                    if ($w) {
                        substr( $from, 1, 1 ) -= 1;
                    }
                    else {
                        $from++;
                    }
                }
                else {
                    $from = $to;

                    if ($w) {
                        substr( $from, 1, 1 ) -= 1;
                        $ep = $from, substr( $from, 1, 1 ) -= 1
                          unless $board{$from};
                    }
                    else {
                        $from++;
                        $ep = $from, $from++ unless $board{$from};
                    }
                }

                if ( substr( $from, 0, 1 ) ne substr( $to, 0, 1 ) ) {
                    if ( not $board{$to} ) {
                        $enpassant = $to;
                        if ($w) {
                            substr( $enpassant, 1, 1 ) =
                              chr( ord( substr( $enpassant, 1, 1 ) ) - 1 );
                        }
                        else {
                            substr( $enpassant, 1, 1 ) =
                              chr( ord( substr( $enpassant, 1, 1 ) ) + 1 );
                        }
                        $board{$enpassant} = undef;
                        print "\$enpassant=$enpassant \$from=$from \$to=$to\n"
                          if $debug;
                    }
                }
                ( $board{$to}, $board{$from} ) =
                  ( $promotion ? $promotion : $board{$from}, undef );
                print "$piece moved from $from to $to\n" if $debug;
                print "$piece promotes to $promotion\n"
                  if $promotion and $debug;
                push ( @epdlist, epd( $w, $Kc, $Qc, $kc, $qc, $ep, %board ) );
                print "$epdlist[-1]\n" if $debug;
            }
            elsif ( $piece eq "KR" ) {
                my ( $k_from, $r_from ) = unpack( "A2A2", $from );
                my ( $k_to,   $r_to )   = unpack( "A2A2", $to );

                ( $board{$k_to}, $board{$k_from} ) = ( $board{$k_from}, undef );
                ( $board{$r_to}, $board{$r_from} ) = ( $board{$r_from}, undef );
                if ($w) {
                    $Kc = $Qc = 0;
                }
                else {
                    $kc = $qc = 0;
                }
                print $w ? "White" : "Black", " castles from $k_from to $k_to\n"
                  if $debug;
                push ( @epdlist, epd( $w, $Kc, $Qc, $kc, $qc, $ep, %board ) );
                print "$epdlist[-1]\n" if $debug;
            }
            else {
                my @piece_at;
                my @fromlist;

                $piece = lc($piece) if not $w;
                @piece_at = psquares( $piece, %board );
                print "\@piece_at=", join ( ",", @piece_at ), "\n" if $debug;
                if ($from) {
                    my @tmp;

                    print "\$from=$from\n" if $debug;
                    if ( $from =~ /[a-h]/ ) {
                        foreach (@piece_at) {
                            push ( @tmp, $_ )
                              if ( substr( $_, 0, 1 ) eq $from );
                        }
                    }
                    else {

                        foreach (@piece_at) {
                            push ( @tmp, $_ )
                              if ( substr( $_, 1, 1 ) eq $from );
                        }
                    }
                    @piece_at = @tmp;
                }

                foreach my $square (@piece_at) {
                    foreach ( @{ $move_table{ uc($piece) }{$square} } ) {
                        push ( @fromlist, $square ) if $_ eq $to;
                    }
                }

                if ( scalar(@fromlist) != 1 ) {
                    print "\@fromlist=", join ( ",", @fromlist ), "\n"
                      if $debug;
                    foreach (@fromlist) {
                        if ( canmove( $piece, $to, $_, %board ) ) {
                            $from = $_;
                            last;
                        }
                    }
                }
                else {
                    $from = $fromlist[0];
                }
                if ($piece =~ /[RrKk]/) {
                    if ($piece eq 'R') {
                        $Kc = 0 if $from eq 'h1';
                        $Qc = 0 if $from eq 'a1';
                    }
                    elsif ($piece eq 'r') {
                        $kc = 0 if $from eq 'h8';
                        $qc = 0 if $from eq 'a8';
                    }
                    elsif ($piece eq 'K') {
                        $Kc = $Qc = 0;
                    }
                    else {
                        $kc = $qc = 0;
                    }
                }
                if ( not( $from or $to ) ) {
                    exit(0);
                }
                ( $board{$to}, $board{$from} ) = ( $board{$from}, undef );
                print "\@piece_at=", join ( ",", @piece_at ), "\n" if $debug;
                print "$piece moved from $from to $to\n" if $debug;
                push ( @epdlist, epd( $w, $Kc, $Qc, $kc, $qc, $ep, %board ) );
                print "$epdlist[-1]\n" if $debug;
                exit(0) if not $from;
            }
            $w ^= 1;
        }
    }
    return @epdlist;
}

sub movetype {
    my ( $w, $move ) = @_;
    my @result = "'$move':Not yet handled";
    my $from;
    my $to;

    if ( $move =~ /^O-O(?:\+|\#)?$/ ) {
        if ($w) {
            $from = "e1h1";
            $to   = "g1f1";
        }
        else {
            $from = "e8h8";
            $to   = "g8f8";
        }
        @result = ( "KR", $to, $from );
    }
    elsif ( $move =~ /^O-O-O(?:\+|\#)?$/ ) {

        if ($w) {
            $from = "e1a1";
            $to   = "c1d1";
        }
        else {
            $from = "e8a8";
            $to   = "c8d8";
        }
        @result = ( "KR", $to, $from );
    }
    elsif ( $move =~ /^([a-h][1-8])(?:\+|\#)?$/ ) {
        @result = ( "P", $1 );
    }
    elsif ( $move =~ /^([a-h])x?([a-h][1-8])(?:\+|\#)?$/ ) {
        @result = ( "P", $2, $1 );
    }
    elsif ( $move =~ /^([a-h][18])=?([RNBQ])(?:\+|\#)?$/ ) {
        @result = ( "P", $1, undef, $2 );
    }
    elsif ( $move =~ /^([a-h])x([a-h][18])=?([RNBQ])(?:\+|\#)?$/ ) {
        @result = ( "P", $2, $1, $3 );
    }
    elsif ( $move =~ /^([RNBQK])([a-h][1-8])(?:\+|\#)?$/ ) {
        @result = ( $1, $2 );
    }
    elsif ( $move =~ /^([RNBQK])x([a-h][1-8])(?:\+|\#)?$/ ) {
        @result = ( $1, $2 );
    }
    elsif ( $move =~ /^([RNBQK])([a-h]|[1-8])([a-h][1-8])(?:\+|\#)?$/ ) {
        @result = ( $1, $3, $2 );
    }
    elsif ( $move =~ /^([RNBQK])([a-h]|[1-8])x([a-h][1-8])(?:\+|\#)?$/ ) {
        @result = ( $1, $3, $2 );
    }
    elsif ( $move =~ /^([RNBQK])([a-h][1-8])x([a-h][1-8])(?:\+|\#)?$/ ) {
        @result = ( $1, $3, $2 );
    }
    return @result;
}

sub psquares {
    my ( $piece, %board ) = @_;
    my $key;
    my $value;
    my @squares;

    while ( ( $key, $value ) = each(%board) ) {
        push ( @squares, $key ) if ( $value and ( $value eq $piece ) );
    }
    return @squares;
}

sub epd {
    my ( $w, $Kc, $Qc, $kc, $qc, $ep, %board ) = @_;
    my @key = qw(
      a8 b8 c8 d8 e8 f8 g8 h8 
      a7 b7 c7 d7 e7 f7 g7 h7 
      a6 b6 c6 d6 e6 f6 g6 h6
      a5 b5 c5 d5 e5 f5 g5 h5
      a4 b4 c4 d4 e4 f4 g4 h4 
      a3 b3 c3 d3 e3 f3 g3 h3
      a2 b2 c2 d2 e2 f2 g2 h2
      a1 b1 c1 d1 e1 f1 g1 h1
    );
    my $n;
    my $piece;
    my $epd;

    foreach ( 0..63) {
        if ( $_ and ( $_ % 8 ) == 0 ) {
            if ($n) {
                $epd .= "$n";
                $n = 0;
            }
            $epd .= "/";
        }
        $piece = $board{ $key[$_] };

        if ($piece) {
            if ($n) {
                $epd .= "$n";
                $n = 0;
            }
            $epd .= $piece;
        }
        else {
            $n++;
        }
    }

    $epd .= "$n" if  $n;
    $epd .= ($w ? " b" : " w");

    if ( $Kc or $Qc or $kc or $qc ) {
        $epd .= " ";
        $epd .= "K" if $Kc;
        $epd .= "Q" if $Qc;
        $epd .= "k" if $kc;
        $epd .= "q" if $qc;
    }
    else {
        $epd .= " -";
    }
    $epd .= " $ep";
    return $epd;
}

sub canmove {
    my ( $piece, $to, $from, %board ) = @_;
    my $lto;
    my $rto;
    my $lfrom;
    my $rfrom;
    my $result = 1;
    my $p;
    my $offset  = 1;
    my $roffset = 1;
    my $loffset = 1;
    my $c       = 0;

    $to =~ /(.)(.)/;
    $lto = $1;
    $rto = $2;
    $from =~ /(.)(.)/;
    $lfrom = $1;
    $rfrom = $2;
    if ( ( $rto eq $rfrom ) or ( $lto eq $lfrom ) ) {

        if ( ( $rto eq $rfrom and $lto lt $lfrom )
          or ( $lto eq $lfrom and $rto lt $rfrom ) )
        {
            $offset = -1;
        }

        if ( $lto eq $lfrom ) {
            $c = 1;
        }
        while ( $from ne $to ) {
            substr( $from, $c, 1 ) =
              chr( ord( substr( $from, $c, 1 ) ) + $offset );

            if ( $p = $board{$from} ) {
                if ( $from ne $to ) {
                    $result = 0;
                }
                last;
            }
        }
    }
    else {

        if ( $rto lt $rfrom ) {
            $roffset = -1;
        }
        if ( $lto lt $lfrom ) {
            $loffset = -1;
        }

        while ( $from ne $to ) {
            substr( $from, 0, 1 ) =
              chr( ord( substr( $from, 0, 1 ) ) + $loffset );
            substr( $from, 1, 1 ) =
              chr( ord( substr( $from, 1, 1 ) ) + $roffset );
            if ( $p = $board{$from} ) {

                if ( $from ne $to ) {
                    $result = 0;
                }
            }
        }
    }

    if ($p) {
        if ( ( $piece =~ /RQB/ and $p =~ /RQBKNP/ )
          or ( $piece =~ /rqb/ and $p =~ /rqbknp/ ) )
        {
            $result = 0;
        }
    }
    return $result;
}

1;
__END__

=head1 NAME

Chess::PGN::EPD - Perl extension to convert an array moves in PGN standard notation, to
EPD form.

=head1 SYNOPSIS

 #!/usr/bin/perl
 #
 # epd.pl -- program to generate epd from .PGN
 #
 use warnings;
 use strict;
 use diagnostics;
 use Chess::PGN::Parse;
 use Chess::PGN::EPD;
 
 if ($ARGV[0]) {
     my $pgn = new Chess::PGN::Parse($ARGV[0]) or die "Can't open $ARGV[0]: $!\n";
     while ($pgn->read_game()) {
         $pgn->parse_game();
         print join ( "\n", epdlist(  @{$pgn->moves()} ) ), "\n\n";
     }
 }

=head1 DESCRIPTION

=head2 EPD

EPD is "Extended Position Description"; it is a standard for describing chess
positions along with an extended set of structured attribute values using the
ASCII character set.  It is intended for data and command interchange among
chessplaying programs.  It is also intended for the representation of portable
opening library repositories.

A single EPD uses one text line of variable length composed of four data field
followed by zero or more operations.  The four fields of the EPD specification
are the same as the first four fields of the FEN specification.

A text file composed exclusively of EPD data records should have a file name
with the suffix ".epd".

EPD is based in part on the earlier FEN standard; it has added extensions for
use with opening library preparation and also for general data and command
interchange among advanced chess programs.  EPD was developed by John Stanback
and Steven Edwards; its first implementation is in Stanback's master strength
chessplaying program Zarkov.

Like FEN, EPD can also be used for general position description.  However,
unlike FEN, EPD is designed to be expandable by the addition of new operations
that provide new functionality as needs arise.

=head2 FEN

FEN is "Forsyth-Edwards Notation"; it is a standard for describing chess
positions using the ASCII character set.

A single FEN record uses one text line of variable length composed of six data
fields.  The first four fields of the FEN specification are the same as the
first four fields of the EPD specification.

A text file composed exclusively of FEN data records should have a file name
with the suffix ".fen".

B<History>

FEN is based on a 19th century standard for position recording designed by the
Scotsman David Forsyth, a newspaper journalist.  The original Forsyth standard
has been slightly extended for use with chess software by Steven Edwards with
assistance from commentators on the Internet.

B<Uses for a position notation>

Having a standard position notation is particularly important for chess
programmers as it allows them to share position databases.  For example, there
exist standard position notation databases with many of the classical benchmark
tests for chessplaying programs, and by using a common position notation format
many hours of tedious data entry can be saved.  Additionally, a position
notation can be useful for page layout programs and for confirming position
status for e-mail competition.

B<Data fields>

FEN specifies the piece placement, the active color, the castling availability,
the en passant target square, the halfmove clock, and the fullmove number.
These can all fit on a single text line in an easily read format.  The length
of a FEN position description varies somewhat according to the position. In
some cases, the description could be eighty or more characters in length and so
may not fit conveniently on some displays.  However, these positions aren't too
common.

A FEN description has six fields.  Each field is composed only of non-blank
printing ASCII characters.  Adjacent fields are separated by a single ASCII
space character.

=over 

=item Piece placement data

The first field represents the placement of the pieces on the board.  The board
contents are specified starting with the eighth rank and ending with the first
rank.  For each rank, the squares are specified from file a to file h.  White
pieces are identified by uppercase SAN piece letters ("PNBRQK") and black
pieces are identified by lowercase SAN piece letters ("pnbrqk").  Empty squares
are represented by the digits one through eight; the digit used represents the
count of contiguous empty squares along a rank.  A solidus character "/" is
used to separate data of adjacent ranks.

=item Active color

The second field represents the active color.  A lower case "w" is used if
White is to move; a lower case "b" is used if Black is the active player.

=item Castling availability

The third field represents castling availability.  This indicates potential
future castling that may of may not be possible at the moment due to blocking
pieces or enemy attacks.  If there is no castling availability for either side,
the single character symbol "-" is used.  Otherwise, a combination of from one
to four characters are present.  If White has kingside castling availability,
the uppercase letter "K" appears.  If White has queenside castling
availability, the uppercase letter "Q" appears.  If Black has kingside castling
availability, the lowercase letter "k" appears.  If Black has queenside
castling availability, then the lowercase letter "q" appears.  Those letters
which appear will be ordered first uppercase before lowercase and second
kingside before queenside.  There is no white space between the letters.

=item En passant target square

The fourth field is the en passant target square.  If there is no en passant
target square then the single character symbol "-" appears.  If there is an en
passant target square then is represented by a lowercase file character
immediately followed by a rank digit.  Obviously, the rank digit will be "3"
following a white pawn double advance (Black is the active color) or else be
the digit "6" after a black pawn double advance (White being the active color).

An en passant target square is given if and only if the last move was a pawn
advance of two squares.  Therefore, an en passant target square field may have
a square name even if there is no pawn of the opposing side that may
immediately execute the en passant capture.

=item Halfmove clock

The fifth field is a nonnegative integer representing the halfmove clock.  This
number is the count of halfmoves (or ply) since the last pawn advance or
capturing move.  This value is used for the fifty move draw rule.

=item Fullmove number

The sixth and last field is a positive integer that gives the fullmove number.
This will have the value "1" for the first move of a game for both White and
Black.  It is incremented by one immediately after each move by Black.

=back

B<Examples>

Here's the FEN for the starting position:

rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1

And after the move 1. e4:

rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1

And then after 1. ... c5:

rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2

And then after 2. Nf3:

rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2

For two kings on their home squares and a white pawn on e2 (White to move) with
thirty eight full moves played with five halfmoves since the last pawn move or
capture:

4k3/8/8/8/8/8/4P3/4K3 w - - 5 39

=head1 NOTE

With only a little observation, the astute user will notice that actually this module
doesn't return either EPD or FEN, but rather a bit of both. It is mostly FEN, but it lacks
the Fullmove number field, since for most usage that information is available else where
or can easily be reconstructed. As to why the module is called EPD, well I figured since it
wasn't one and it wasn't the other, that left it up to me to choose--besides, who would want
a module named after a swamp?!

=head2 EXPORT

=over

=item epdlist

=back

=head2 DEPENDENCIES

=over

=item CHESS::PGN::MOVES

=item CHESS::PGN::PGNParser (useless without, not actually required though...)

=back

=head1 TODO

=over

=item Various epd to string conversion routines for typesetting, html etc...

=back

=head1 KNOWN BUGS

None known; Unknown? Of course, though I try to be neat...

=head1 AUTHOR

B<I<Hugh S. Myers>>

=over

=item Always: hsmyers@sdragons.com

=back

=cut
