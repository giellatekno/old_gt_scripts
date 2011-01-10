use Test::More 'no_plan';
use Test::Exception;
use strict;
use Cwd;
use Encode;
use utf8;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::Converter');
}
require_ok('langTools::Converter');

#
# Set a file name, try to make an instance of our object
#
#
my @doc_names = ("$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/s3_lohkki_NSR.article_2.xml", "$ENV{'GTBOUND'}/orig/sme/bible/ot/Salmmat__garvasat.bible.xml", "$ENV{'GTBOUND'}/orig/nno/bible/ot/01GENNNST.u8.ptx", "$ENV{'GTBOUND'}/orig/sma/admin/depts/Samisk_som_andresprak_sorsamisk.rtf", "$ENV{'GTFREE'}/orig/sma/admin/depts/regjeringen.no/arromelastoeviertieh-prosjektasse--laavlomefaamoe-berlevagesne.html?id=609232", "$ENV{'GTFREE'}/orig/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc", "$ENV{'GTFREE'}/orig/sma/facta/skuvlahistorja1/albert_s.html", "$ENV{'GTFREE'}/orig/sme/laws/nac1-1994-24.txt", "$ENV{'GTFREE'}/orig/sme/facta/callinravvagat.pdf", "$ENV{'GTBOUND'}/orig/sme/facta/RidduRiđđu-aviissat/Riddu_Riddu_avis_TXT_200612.svg", "$ENV{'GTFREE'}/orig/dan/facta/skuvlahistorja4/stockfleth-n.htm");
foreach my $doc_name (@doc_names) {
	print "\nTrying to convert $doc_name\n";
	ok(my $converter = langTools::Converter->new($doc_name, 0));

	#
	# Test if the original is the given file name
	#
	is($converter->getOrig(), Encode::decode_utf8(Cwd::abs_path($doc_name)));

	(my $int = $converter->getOrig()) =~ s/\/orig\//\/converted\//;
	is($converter->getInt(), $int .".xml", "Check if path to the converted doc is computed correctly");

	is(length($converter->getTmpFilebase()), '8');

	is($converter->getCommonXsl(), "$ENV{'GTHOME'}/gt/script/corpus/common.xsl", "Check if common.xsl is set");

	is($converter->getPreprocXsl(), "$ENV{'GTHOME'}/gt/script/corpus/preprocxsl.xsl", "Check if preprocxsl.xsl is set");

	isnt($converter->getDoclang(), "", "Check if doclang is empty");

	is($converter->makeXslFile(), '0', "Check if we are able to make the tmp-metadata file");

	is($converter->convert2xml(), '0', "Check if combination of internal xml and metadata goes well");

	is($converter->checklang(), '0', "Check lang. If not set, set it");

	is($converter->checkxml(), '0', "Check if the final xml is valid");
}
