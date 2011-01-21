use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use strict;
use Cwd;
use Encode;
use utf8;
use Getopt::Long;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::Converter');
}
require_ok('langTools::Converter');

my $debug = 0;
GetOptions ("debug" => \$debug);
print "debug is $debug $#ARGV\n";

my $numArgs = $#ARGV + 1;
if ($#ARGV > -1) {
	foreach my $argnum (0 .. $#ARGV) {
		each_file_checks($ARGV[$argnum]);
	}
} else {
	my @doc_names = (
	"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/2.html?id=170397", 
	"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/oktavuohtadiehtojuohkin.html?id=306", 
	"$ENV{'GTFREE'}/orig/sme/admin/sd/Strategalaš_plána_sámi_mánáidgárddiide_2001–2005.pdf", "$ENV{'GTFREE'}/orig/sme/laws/Lovom037.pdf",
	"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/s3_lohkki_NSR.article_2.xml",
	"$ENV{'GTBOUND'}/orig/sme/bible/ot/Salmmat__garvasat.bible.xml",
	"$ENV{'GTBOUND'}/orig/nno/bible/ot/01GENNNST.u8.ptx",
	"$ENV{'GTBOUND'}/orig/sma/admin/depts/Samisk_som_andresprak_sorsamisk.rtf",
	"$ENV{'GTFREE'}/orig/sma/admin/depts/regjeringen.no/arromelastoeviertieh-prosjektasse--laavlomefaamoe-berlevagesne.html?id=609232",
	"$ENV{'GTFREE'}/orig/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc",
	"$ENV{'GTFREE'}/orig/sma/facta/skuvlahistorja1/albert_s.html",
	"$ENV{'GTFREE'}/orig/sme/laws/nac1-1994-24.txt",
	"$ENV{'GTFREE'}/orig/sme/facta/callinravvagat.pdf",
	"$ENV{'GTBOUND'}/orig/sme/facta/RidduRiđđu-aviissat/Riddu_Riddu_avis_TXT_200612.svg",
	"$ENV{'GTFREE'}/orig/sme/laws/jus.txt",
	"$ENV{'GTFREE'}/orig/dan/facta/skuvlahistorja4/stockfleth-n.htm",
	"$ENV{'GTFREE'}/orig/sma/facta/Utlysningsteks_sørsamisk_2_.doc",
	"$ENV{'GTFREE'}/orig/sma/facta/moerh.pdf",
	"$ENV{'GTFREE'}/orig/sma/admin/depts/Handlingsplan_2009_samisk_sprak_sorsamisk.pdf",
	"$ENV{'GTFREE'}/orig/sme/admin/sd/samediggi.no/samediggi-article-3299.html"
	);

	one_time_checks($doc_names[0]);
	foreach my $doc_name (@doc_names) {
		each_file_checks($doc_name);
	}
}

sub one_time_checks {
	my ($doc_name) = @_;

	ok(my $converter = langTools::Converter->new($doc_name, $debug));
	is($converter->getCommonXsl(), "$ENV{'GTHOME'}/gt/script/corpus/common.xsl", "Check if common.xsl is set");
	is($converter->getPreprocXsl(), "$ENV{'GTHOME'}/gt/script/corpus/preprocxsl.xsl", "Check if preprocxsl.xsl is set");
	is(check_decode_para($converter), '0', "Check if decode para works");
}

sub each_file_checks {
	my ($doc_name) = @_;

	print "\nTrying to convert $doc_name\n";
	ok(my $converter = langTools::Converter->new($doc_name, $debug));
	is($converter->getOrig(), Encode::decode_utf8(Cwd::abs_path($doc_name)));
	is($converter->getInt(), $converter->getTmpDir() . "/" . $converter->getTmpFilebase() . ".xml", "Check if path to the converted doc is computed correctly");
	is(length($converter->getTmpFilebase()), '8');
	is($converter->makeXslFile(), '0', "Check if we are able to make the tmp-metadata file");
	is($converter->convert2intermediatexml(), '0', "Check if we are able to make an intermediate xml file");
	is($converter->convert2xml(), '0', "Check if combination of internal xml and metadata goes well");
	is($converter->checklang(), '0', "Check lang. If not set, set it");
	is($converter->checkxml(), '0', "Check if the final xml is valid");
	is($converter->character_encoding(), '0', "Fix character encoding");
	is($converter->search_for_faulty_characters(), '0', "Content of " . $converter->getInt() . " is wrongly encoded");
	is($converter->checkxml(), '0', "Check if the final xml is valid");
	file_exists_ok($converter->move_int_to_converted(), "Check if xml has been moved to final destination");
	$converter->remove_temp_files();
	file_not_exists_ok( $converter->getInt() );
	file_not_exists_ok( $converter->getIntermediateXml() );
	file_not_exists_ok( $converter->getPreconverter->gettmp2() );
	file_not_exists_ok( $converter->getMetadataXsl() );
}


use XML::Twig;
use samiChar::Decode;

sub check_decode_para {
	my ($converter) = @_;
	
	my $error = 0;
	my $tmp = "Converter-data/Lovom037.pdf.xml";
	my $document = XML::Twig->new;
	if ( $document->safe_parsefile("$tmp")) {
		my $root = $document->root;
		my $sub = $root->{'last_child'}->{'first_child'};
		&read_char_tables;
		$error = $converter->call_decode_para($document, $sub, "samimac_roman");
	} else {
		die "ERROR parsing the XML-file «$tmp» failed ";
	}
	
	return $error;
}
