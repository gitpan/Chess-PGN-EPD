use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
my @list_of_db_files = ( 'db/ECO.stor', 'db/NIC.stor', 'db/Opening.stor' );

WriteMakefile(
    'NAME'         => 'Chess::PGN::EPD',
    'VERSION_FROM' => 'EPD.pm',            # finds $VERSION
    'PREREQ_PM'    => {
        Chess::PGN::Moves     => 0.04,
        Chess::PGN::Parse     => 0.19,
        Test::More            => 0.94,
        Text::CSV             => 1.18,
        Storable              => 2.21,
        Cwd                   => 3.31,
        Try::Tiny             => 0.06
    },                                     # e.g., Module::Name => 1.1
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM => 'EPD.pm',    # retrieve abstract from module
            AUTHOR => 'Hugh S. Myers <hsmyers@gmail.com>'
          )
        : ()
    ),
);

sub MY::post_constants {
    join( "\n",
        'INSTALL_DB_FILES=$(INSTALLSITELIB)/Chess/PGN/db',
        "DB_FILES=@list_of_db_files" );
}

sub MY::postamble {
    <<'EXTRA';
install :: install.dbfiles

install.dbfiles:: $(DB_FILES)
	$(MKPATH) $(INSTALL_DB_FILES)
	$(CP) $(DB_FILES) $(INSTALL_DB_FILES)

all :: FORCE
	$(PERL) scripts/db.pl

FORCE:
EXTRA
}
