#!/usr/bin/perl
# db.pl -- Create ECO, NIC, Opening Berkeley DBs.
#  
use strict;
use warnings;
use diagnostics;
use DB_File;
use Text::CSV;

my $path = "CSV/";
my $csv = Text::CSV->new();
my $status;
my @columns;
my %h;
my @files = ('ECO','NIC','Opening');

mkdir('db');
foreach my $file (@files) {
    if (-e "db/$file") {
        print "$file exists ok\n";
        next;
    }
    print "Building $file ";
    tie %h, "DB_File", "db/$file", O_RDWR|O_CREAT, 0644, $DB_HASH
        or die "Couldn't open '$file': $!\n";
    open(IN,"$path$file.txt") or die "Couldn't open '$path$file.txt': $!\n";
    while (<IN>) {
        $status = $csv->parse($_);
        @columns = $csv->fields();
        $h{$columns[1]} = $columns[0];
    }
    close(IN);
    untie %h;
    print "ok\n";
}

