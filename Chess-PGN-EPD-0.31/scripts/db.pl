#!/usr/bin/perl
# db.pl -- Create ECO, NIC, Storable DBs.
#  
use strict;
use warnings;
use diagnostics;
use Text::CSV;
use Storable;

my $path = "CSV/";
my $csv = Text::CSV->new();
my $status;
my @columns;

mkdir('db');
for my $file qw(ECO NIC Opening) {
    my %h;
    if (-e "db/$file.stor") {
        print "$file exists ok\n";
        next;
    }
    print "Source $path$file.txt\n";
    print "Building $file.stor ";
    open(IN,"$path$file.txt") 
        or die "Couldn't open '$path$file.txt': $!\n";
    while (<IN>) {
        $status = $csv->parse($_);
        @columns = $csv->fields();
        $h{$columns[1]} = $columns[0];
    }
    close(IN);
    store \%h, "db/$file.stor";
    print "ok\n";
}

