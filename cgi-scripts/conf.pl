#!/usr/bin/perl -w

use utf8;

# Show custom text to remote viewer
CGI::Alert::custom_browser_text <<END;
Content-type: text/html

	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
		<html>
		<head>
		<meta http-equiv="Content-type" content="text/html; charset=UTF-8"><h1>Error in the analysis.</h1>
<p>[MSG]</p>
<p><a href="http://www.giellatekno.uit.no/">Back</a> </p>
<p><a href="http://giellatekno.uit.no/">giellatekno.uit.no</a></p>
END

@EXPORT = qw(&init_variables);

sub init_variables {

	$uit_href="http://uit.no/";
	$giellatekno_href="http://giellatekno.uit.no/";
	$projectlogo = "http://giellatekno.uit.no/images/project.png";
	$unilogo = "http://giellatekno.uit.no/images/unilogo_mid.gif";

	my %page_languages = (sme => 1,
						  eng => 1,
						  nno => 1);

	%avail_pos = (Any => 1,
				  N => 1 ,
				  V => 1 ,
				  A => 1,
				  Adv => 1,
				  Pron => 1,
				  Num => 1);

	
	$wordlimit = 450 ;       # adjust as appropriate; prevent large-scale use
	
    # System-Specific directories
    # The directory where utilities like 'lookup' are stored
	my $utilitydir = "/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin";
    # The directory for vislcg and lookup2cg
	my $bindir = "/opt/sami/cg/bin/";
    # The directory for hfst tools
        my $hfstutilitydir = "/opt/local/bin";
        my $hfstoptimizedlookup = "hfst-optimized-lookup";

    # The fst's and other tools
	my $optdir = "/opt/smi";
	my $commondir = "/opt/smi/common/bin";
	my $fstdir = "$optdir/$lang/bin" ;

	my $tmpdir = "/tmp";
	$tmpfile=$tmpdir . "/smi-test2.txt";
	my $time = `date +%m-%d-%H-%M`;
	chomp $time;
	$logfile = $tmpdir . "/cgi-" . $time . ".log";
		
	$tagfile = "$fstdir/korpustags.$lang.txt";
	if (! -f $tagfile) { $tagfile="$commondir/korpustags.txt"; }
	
	my $fst = "$fstdir/$lang.fst";
        my $hfst = "$fstdir/$lang.cg.hfst.ol
    my $gen_fst = "$fstdir/i$lang.fst";
    my $gen_norm_fst = "$fstdir/i$lang-norm.fst";
	my $hyph_fst = "$fstdir/hyph-$lang.fst";
	my $hyphrules_fst = "$fstdir/hyphrules-$lang.fst";
	my $num_fst = "$fstdir/$lang-num.fst";
	my $phon_fst = "$fstdir/phon-$lang.fst";
	my $orth_fst = "$fstdir/orth-$lang.fst";
	my $tok_fst = "$fstdir/tok.fst";
        my $fstflags = "-flags mbTT -utf8";
#    my $dis_rle = "$fstdir/$lang-dis.rle"; # text file
    my $dis_bin = "$fstdir/$lang-dis.bin";  # binary file
    my $dep_bin = "$fstdir/$lang-dep.bin";  # binary file
	my $translate_script;
	my $translate_lex;
	my $translate_fst;
    my $geo_fst = "$commondir/geo.fst";
	if ($tr_lang ne "none") {
		if ($lang eq "dan") { 
			$translate_script = "$fstdir/addtrad_$lang$tr_lang.pl";
			$translate_lex = "$fstdir/$lang$tr_lang-lex.txt";
			$translate = "$translate_script $translate_lex";
		}
		else {
			$translate_script = "$commondir/translate.pl";
			$translate_fst = "$fstdir/$lang$tr_lang.fst";
			$translate = "$translate_script --fst=$translate_fst";
		}
	}
	if (-f $fst) { $lang_actions{analyze} = 1; }
#	if (-f $dis_rle) { $lang_actions{disamb} = 1; } # text file
	if (-f $dis_bin) { $lang_actions{disamb} = 1; } # binary file
	if (-f $dep_bin) { $lang_actions{dependency} = 1; } # binary file
	if (-f $hyph_fst) { $lang_actions{hyphenate} = 1; }
	if (-f $phon_fst) { $lang_actions{transcribe} = 1; }
	if (-f $orth_fst) { $lang_actions{convert} = 1; }

	# Find out which of the translated languages are available for this lang.
	my $translated_langs = qw(dan nob);
	for my $tr_avail_lang ( $translated_langs ) {
		$lex = "$fstdir/$lang$tr_avail_lang" . "-lex.txt";
		$fst_tr = "$fstdir/$lang$tr_avail_lang" . ".fst";
		if (-f $lex || -f $fst_tr) { $lang_actions{translate}{$tr_avail_lang} = 1; }
	}

    # Files to generate paradigm
	# Search first the language-specific paradigms, otherwise use
	# the paradigmfiles for sme.
	if ($action eq "paradigm") {
		%paradigmfiles = (
						  minimal => "$fstdir/paradigm_min.$lang.txt",
						  standard => "$fstdir/paradigm_standard.$lang.txt",
						  full => "$fstdir/paradigm_full.$lang.txt",
						  dialect => "$fstdir/paradigm_full.$lang.txt",
						  );
		if ($mode) { $paradigmfile = $paradigmfiles{$mode}; }
		if (! $mode || ! -f $paradigmfile) { $paradigmfile="$fstdir/paradigm.$lang.txt"; }
		if (! -f $paradigmfile) { $paradigmfile="$commondir/paradigm.txt"; }

	if (-f $paradigmfiles{minimal}) { $lang_actions{minimal} = 1; }
	if (-f $paradigmfiles{standard}) { $lang_actions{standard} = 1; }
	if (-f $paradigmfiles{full} || -f $gen_norm_fst ) { $lang_actions{full} = 1; }
	}
	if (-f $gen_norm_fst) { $lang_actions{dialect} = 1; }
	else { $gen_norm_fst = $gen_fst; }

	if ($action eq "analyze" && ! -f $fst) { 
		http_die '--no-alert','404 Not Found',"$lang.fst: Analysis is not supported";
	}
#	if ($action eq "disamb" && ! -f $dis_rle) { 
#		http_die '--no-alert','404 Not Found',"$lang-dis.rle: Disambiguation is not supported";
	if ($action eq "disamb" && ! -f $dis_bin) { 
		http_die '--no-alert','404 Not Found',"$lang-dis.bin: Disambiguation is not supported";
	}
	if ($action eq "dependency" && ! -f $dep_bin) { 
		http_die '--no-alert','404 Not Found',"$lang-dep.bin: Dependency analysis is not supported";
	}
	if ($action eq "generate" && ! -f $gen_fst) {
		http_die '--no-alert','404 Not Found',"i$lang.fst: Generation is not supported";
	}
	if ($action eq "hyphenate" && ! -f $hyph_fst) {
		http_die '--no-alert','404 Not Found',"hyph-$lang.fst: Hyphenation is not supported";
	}
	if ($action eq "transcribe" && ! -f $phon_fst) {
		http_die '--no-alert','404 Not Found',"phon-$lang.fst: Phonetic representation is not supported";
	}

	if ($action eq "convert" && ! -f $orth_fst) {
		http_die '--no-alert','404 Not Found',"orth-$lang.fst: Orthographic representatoin is not supported";
	}
	if ($action eq "paradigm" && ! -f $gen_fst) {
		http_die '--no-alert','404 Not Found',"i$lang.fst: Paradigm generation is not supported";
	}
	if ($tr_lang ne "none" && ( ! -f $translate_script && ! -f $translate_lex && -f $translate_fst ) ) { 
		http_die '--no-alert','404 Not Found', "Translation to language \"$tr_lang\" is not supported";
	}
	if (!$plang || ! $page_languages{$plang}) { $plang = "eng"; }

	if (-f "$fstdir/abbr.txt") {
		$preprocess = "$bindir/preprocess --abbr=$fstdir/abbr.txt";
	}
	if ($lang eq "cor") {
	    $preprocess = "$utilitydir/tokenize $tok_fst";
	}
	else { $preprocess = "$bindir/preprocess"; }


    $analyze = "$preprocess | $utilitydir/lookup $fstflags $fst";
    $hfstanalyze = "$preprocess | $hfstutilitydir/hfst-optimized-lookup $hfst";

	if ($lang eq "fin") { $analyse = $hfstanalyse; }

	$disamb = "$analyze | $bindir/lookup2cg | $bindir/vislcg3 -g $dis_bin -C UTF-8"; 
	$dependency = "$analyze | $bindir/lookup2cg | $bindir/vislcg3 -g $dis_bin -C UTF-8 | $bindir/vislcg3 -g $dep_bin -C UTF-8"; 
# for the next debug, this is the variable-free version of $disamb:
# $disamb = /opt/sami/cg/bin/preprocess --abbr=/opt/smi/sme/bin/abbr.txt | /opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup -flags mbTT -utf8 /opt/smi/sme/bin/sme.fst | /opt/sami/cg/bin/lookup2cg | /opt/sami/cg/bin/vislcg3 -g /opt/smi/sme/bin/sme-dis.bin -C UTF-8
	$gen_lookup = "$utilitydir/lookup $fstflags -d $gen_fst" ;
	$gen_norm_lookup = "$utilitydir/lookup $fstflags -d $gen_norm_fst" ;
    $generate = "tr ' ' '\n' | $gen_lookup";
    $generate_norm = "tr ' ' '\n' | $gen_norm_lookup";
    $hyphenate = "$preprocess | $utilitydir/lookup $fstflags $hyph_fst | $commondir/hyph-filter.pl";
    $transcribe = "$preprocess | $utilitydir/lookup $fstflags $phon_fst";
    my $complextranscribe = "$preprocess | $utilitydir/lookup $fstflags $num_fst | cut -f2 | $utilitydir/lookup $fstflags $hyphrules_fst | cut -f2 | $utilitydir/lookup $fstflags $phon_fst" ;

	$placenames = "$utilitydir/lookup $fstflags $geo_fst";

	if ($lang eq "sme") { $transcribe = $complextranscribe; }
    $convert = "$preprocess | $utilitydir/lookup $fstflags $orth_fst";

    # File where the language is stored.
	$langfile="$commondir/cgi-$plang.xml";
}

1; 
