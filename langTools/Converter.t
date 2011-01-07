use strict;

use Test::More tests => 7;
use Test::Exception;

my $doc_name = "orig/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc";

BEGIN {
	use_ok('langTools::Converter');
}
ok(my $converter = langTools::Converter->new($doc_name, 0));
is($converter->getOrig(), "$doc_name");
is($converter->getInt(), "converted/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc.xml");
is(length($converter->getFile()), '8');
is($converter->convert2xml, '0');
is($converter->makeXslFile(), '0');