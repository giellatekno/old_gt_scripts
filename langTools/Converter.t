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
$samiChar::Decode::Test = $debug;

my $numArgs = $#ARGV + 1;
if ($#ARGV > -1) {
	foreach my $argnum (0 .. $#ARGV) {
		each_file_checks($ARGV[$argnum]);
	}
} else {
	my @doc_names = (
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2004/007_04/_VM_Kroa_MLA.txt",
	"$ENV{'GTBOUND'}/orig/nob/facta/other_files/Nordområdestrategi06.pdf",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2004/101-04_Scooter/_Midts._fra_Fred_2610,_sami.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2003/other_files/_Lohkki_Mathisen.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/056-2007/_JK-kronihkka-guolli.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/026-06/_JK-arbe.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/002-06/_JK-Kron-sami.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/011-05/_Govvamuitu_nr_6.txt",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/029-05/_ÅP-Májjá_gávppaša.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/004-07/_Alm-GP_driftstekniker.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/023-07/_Alm-Bilfører_65+.doc",
	"$ENV{'GTBOUND'}/orig/smj/facta/other_files/Aktisasj_goahte_-_biejvvegirjásj_-_Samefolket_6.4.2006.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/039-05/_AJG-NYjoatkaskuvla.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/075-2007/_AH-Manglende_samepolitikk_i_Sverige_.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/046-05/_AH-kummalohkki,_NY.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/101-05/_AJ-porsanger.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/034-07/_AJ-Ohcejoga_proseakta.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/036-05/_AJ-katrine_boine.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/016-07/_AJ-juoigan.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/017-06/_AJ-Josef_vedhuggnes.doc",
	"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/046-06/_1side-46.doc",
"$ENV{'GTFREE'}/orig/sme/admin/depts/other_files/Hoeringsnotat_forskrift_rammeplan_samiske_grunnskolelaererutdanninger_samiskversjon.pdf",
	"$ENV{'GTBOUND'}/goldstandard/orig/sme/facta/printfriendly.aspx",
	"$ENV{'GTBOUND'}/goldstandard/orig/sme/facta/index.php",
	"$ENV{'GTBOUND'}/goldstandard/orig/sme/facta/Barnehageplan_Samisk_3.pdf.correct.xml",
	"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/2.html_id=170397", 
	"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/oktavuohtadiehtojuohkin.html_id=306", 
	"$ENV{'GTFREE'}/orig/sme/admin/sd/other_files/Strategalaš_plána_sámi_mánáidgárddiide_2001–2005.pdf", "$ENV{'GTFREE'}/orig/sme/laws/other_files/Lovom037.pdf",
	"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/s3_lohkki_NSR.article_2.xml",
	"$ENV{'GTBOUND'}/orig/sme/bible/ot/Salmmat__garvasat.bible.xml",
	"$ENV{'GTBOUND'}/orig/nno/bible/ot/01GENNNST.u8.ptx",
	"$ENV{'GTBOUND'}/orig/sma/admin/depts/Samisk_som_andresprak_sorsamisk.rtf",
	"$ENV{'GTFREE'}/orig/sma/admin/depts/regjeringen.no/arromelastoeviertieh-prosjektasse--laavlomefaamoe-berlevagesne.html_id=609232",
	"$ENV{'GTFREE'}/orig/sme/facta/other_files/psykiatriijavideo_nr_1_-_abc-company.doc",
	"$ENV{'GTFREE'}/orig/sma/facta/skuvlahistorja1/albert_s.html",
	"$ENV{'GTFREE'}/orig/sme/laws/other_files/nac1-1994-24.txt",
	"$ENV{'GTFREE'}/orig/sme/facta/other_files/callinravvagat.pdf",
	"$ENV{'GTBOUND'}/orig/sme/facta/RidduRiđđu-aviissat/Riddu_Riddu_avis_TXT_200612.svg",
	"$ENV{'GTFREE'}/orig/sme/laws/other_files/jus.txt",
	"$ENV{'GTFREE'}/orig/dan/facta/skuvlahistorja4/stockfleth-n.htm",
	"$ENV{'GTFREE'}/orig/sma/facta/other_files/Utlysningsteks_sørsamisk_2_.doc",
	"$ENV{'GTFREE'}/orig/sma/facta/other_files/moerh.pdf",
	"$ENV{'GTFREE'}/orig/sma/admin/depts/other_files/Handlingsplan_2009_samisk_sprak_sorsamisk.pdf",
	"$ENV{'GTFREE'}/orig/sme/admin/sd/samediggi.no/samediggi-article-3299.html",
	"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/stahtaalli-ola-t-heggem-.html_id=1689",
 	"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/norgga-ruoa-ovttasbargu-nannejuvvo-vel-eambbo.html_id=601912",
	"$ENV{'GTBOUND'}/orig/sma/facta/other_files/AKTEPJ~1.DOC",
	"$ENV{'GTFREE'}/orig/nob/admin/others/aktivitetsplan_2002_no.doc",
	"$ENV{'GTFREE'}/orig/nob/admin/sd/samediggi.no/samediggi-article-84.html",
	"$ENV{'GTFREE'}/orig/sma/admin/depts/other_files/Åarjelsaemien_gïelen_divvun.doc",
	"$ENV{'GTFREE'}/orig/sme/admin/guovda/Čoahkkinprotokolla_27.06.02.doc",
	"$ENV{'GTFREE'}/orig/sme/admin/guovda/Dá_lea_gihppagaš_mas_leat_dieđut_skuvlla_birra.doc",
	"$ENV{'GTFREE'}/orig/sme/admin/others/Tillegg_til_forskrift_vann-_og_avløpsgebyrer_2004.doc",
	"$ENV{'GTFREE'}/orig/sma/admin/depts/other_files/Torkel_saemien_divvun.doc",
	"$ENV{'GTBOUND'}/orig/sma/facta/other_files/Vi_vill___MP.pdf",
	"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2010_xml-filer/SL_Einar_Wiggo_Isaksen(a).article.xml",
	"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/SL_Enare_&_Østsamisk.article.xml",
	"$ENV{'GTBOUND'}/orig/sme/news/Assu/1998/Assunr.47/03-47-NB2.txt",
	"$ENV{'GTBOUND'}/orig/sme/news/Assu/1998/Assunr.94/10-94-kronihkka.txt",
	"$ENV{'GTBOUND'}/orig/kal/news/AG/2008/AG02_2008.pdf",
	"$ENV{'GTBOUND'}/orig/kal/news/AG/2008/AG05_2008.pdf",
	"$ENV{'GTBOUND'}/orig/kal/news/AG/2008/AG15_2008.pdf",
	"$ENV{'GTBOUND'}/orig/kal/news/AG/2008/AG21_2008.pdf",
	"$ENV{'GTBOUND'}/orig/sme/news/avvir.no/avvir-article-1258.txt",
# 	"$ENV{'GTFREE'}/orig/nno/admin/depts/regjeringen.no/tema.html_id=423"
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
	is($converter->add_error_markup(), '0', "Add error markup");
	is($converter->search_for_faulty_characters($converter->getInt()), '0', "Content of " . $converter->getInt() . " is correctly encoded");
	is($converter->text_categorization(), '0', "Check if text categorization goes well");
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
