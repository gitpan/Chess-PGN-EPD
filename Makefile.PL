use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
my @list_of_db_files = ('db/ECO','db/NIC','db/Opening');

WriteMakefile(
    'NAME'		=> 'Chess::PGN::EPD',
    'VERSION_FROM'	=> 'EPD.pm', # finds $VERSION
    'PREREQ_PM'		=> {
		Chess::PGN::Moves => 0.03,
		DB_File => 1.73,
		Test => 1.15,
        Text::CSV => 0.01,
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'EPD.pm', # retrieve abstract from module
       AUTHOR     => 'Hugh S. Myers <hsmyers@sdragons.com>') : ()),
);

sub MY::post_constants {
    join("\n",
        'INSTALL_DB_FILES=$(INSTALLSITELIB)/Chess/PGN/db',
        "DB_FILES=@list_of_db_files");
}

sub MY::postamble { <<'EXTRA';
install :: install.dbfiles

install.dbfiles:: $(DB_FILES)
	$(MKPATH) $(INSTALL_DB_FILES)
	$(CP) $(DB_FILES) $(INSTALL_DB_FILES)

all :: FORCE
	$(PERL) scripts/db.pl

FORCE:
EXTRA
}