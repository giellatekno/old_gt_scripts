#!/usr/bin/perl -w

use utf8;

# Show custom text to remote viewer
CGI::Alert::custom_browser_text <<END;
Content-type: text/html

	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "https://www.w3.org/TR/html4/loose.dtd">
		<html>
		<head>
		<meta http-equiv="Content-type" content="text/html; charset=UTF-8"><h1>Error in the analysis.</h1>
<p>[MSG]</p>
<p><a href="https://www.giellatekno.uit.no/">Back</a> </p>
<p><a href="https://giellatekno.uit.no/">giellatekno.uit.no</a></p>
END

@EXPORT = qw(&init_variables);

sub init_variables {

	$uit_href="https://uit.no/";
	$giellatekno_href="https://giellatekno.uit.no/";
	$projectlogo = "https://giellatekno.uit.no/images/giellatekno_logo_official.png";
	$unilogo = "https://giellatekno.uit.no/images/unilogo_mid.png";
	$analyze = "";
	my %page_languages = (sme => 1,
			      sma => 1,
			      eng => 1,
			      nno => 1,
			      fin => 1,
			      rus => 1);
	
	%avail_pos = (Any => 1,
		      N => 1 ,
		      V => 1 ,
		      A => 1,
		      Adv => 1,
		      Pron => 1,
		      Num => 1);

	if (!$lang) { $lang=''; }

	$wordlimit = 450 ;       # adjust as appropriate; prevent large-scale use
	
	# System-Specific directories
	# The directory where utilities like 'lookup' are stored
	my $utilitydir = "/usr/local/bin"; 
	# The directory for vislcg and lookup2cg
	my $bindir = "/usr/bin"; # 
	# The directory for hfst tools
    my $hfstutilitydir = "/usr/bin";
	my $hfst_lookup = "$hfstutilitydir/hfst-lookup";
	
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
	
	my $fst = "$fstdir/analyser-disamb-gt-desc.hfstol";
	my $fst_without_semtags = "$fstdir/analyser-gt-desc.hfstol";
	my $hfst_tokenize = "$fstdir/tokeniser-disamb-gt-desc.pmhfst"; # --enable-tokenisers
	my $has_tokenizer = 0 ;
	my $gen_fst = "$fstdir/generator-gt-desc.hfstol";
	my $gen_norm_fst = "$fstdir/generator-gt-norm.hfstol";
	my $hyph_fst = "$fstdir/hyphenator-gt-desc.hfstol"; # --enable-fst-hyphenator
	my $num_fst = "$fstdir/transcriptor-numbers-digit2text.filtered.lookup.hfstol";
	my $phon_fst = "$fstdir/txt2ipa.compose.hfst"; # --enable-phonetic
	my $orth_fst = "$fstdir/oldorthography2norm.compose.hfst"; # only for kal
	my $lat2syll_fst = "$fstdir/Latn-to-Cans.compose.hfst"; # previously latin2syllabics.xfst. Only for crk
	my $syll2lat_fst = "$fstdir/Cans-to-Latn.compose.hfst"; # previously syllabics2latin.xfst. Only for crk
  	my $fstflags = "-flags mbTT -utf8";
	my $hfstflags = "-q --beam=0";
  	my $dis_rle = "$fstdir/disambiguator.cg3";  # text file
	my $dis_bin = "$fstdir/disambiguator.bin";  # binary file
	my $syn_rle = "$fstdir/korp.cg3";    # all-Saami syn file
	my $dep_rle = "$fstdir/dependency.cg3";  # text
	my $dep_bin = "$fstdir/dependency.bin";  # binary file
	my $translate_script;
	my $translate_lex;
	my $translate_fst;
	my $geo_fst = "$commondir/geo.hfst";
	if ($tr_lang ne "none") {
		if ($lang eq "dan") { 
			$translate_script = "$fstdir/addtrad_$lang$tr_lang.pl";
			$translate_lex = "$fstdir/$lang$tr_lang-lex.txt";
			$translate = "$translate_script $translate_lex";
		}
		else {
			$translate_script = "$commondir/translate.pl";
			$translate_fst = "$fstdir/$lang$tr_lang-all.fst";
			$translate = "$translate_script --fst=$translate_fst";
		}
	}
	if (-f $fst) { $lang_actions{analyze} = 1; }
	if (-f $dis_rle) { $lang_actions{disamb} = 1; } # text file
	#	if (-f $dis_bin) { $lang_actions{disamb} = 1; } # binary file
	if (-f $dep_rle) { $lang_actions{dependency} = 1; } # text file
	#	if (-f $dep_bin) { $lang_actions{dependency} = 1; } # binary file
	if (-f $hyph_fst) { $lang_actions{hyphenate} = 1; }
	if (-f $phon_fst) { $lang_actions{transcribe} = 1; }
	if (-f $orth_fst) { $lang_actions{convert} = 1; }
	if (-f $lat2syll_fst) { $lang_actions{lat2syll} = 1; }
	if (-f $syll2lat_fst) { $lang_actions{syll2lat} = 1; }

	# Find out which of the translated languages are available for this lang.
	my @translated_langs = qw(dan nob);
	for (@translated_langs) {
		$lex = "$fstdir/$lang$_" . "-lex.txt";
		$fst_tr = "$fstdir/$lang$_" . ".fst";
		if (-f $lex || -f $fst_tr) { $lang_actions{translate}{$_} = 1; }
	}

    # Files to generate paradigm
	# Search first the language-specific paradigms, otherwise use
	# the paradigmfiles for sme.
	if ($action eq "paradigm") {
		%paradigmfiles = (
						  minimal => "$fstdir/paradigm_min.$lang.txt",
						  standard => "$fstdir/paradigm_standard.$lang.txt",
						  full => "$fstdir/paradigm_full.$lang.txt",
						  test => "$fstdir/paradigm_test.$lang.txt",
						  dialect => "$fstdir/paradigm_full.$lang.txt",
						  );
		if ($mode) { $paradigmfile = $paradigmfiles{$mode}; }
		if (! $mode || ! -f $paradigmfile) { $paradigmfile="$fstdir/paradigm.$lang.txt"; }
		if (! -f $paradigmfile) { $paradigmfile="$commondir/paradigm.txt"; }

    if (-f $paradigmfiles{minimal}) { $lang_actions{minimal} = 1; }
    if (-f $paradigmfiles{standard}) { $lang_actions{standard} = 1; }
    if (-f $paradigmfiles{full} || -f $gen_norm_fst ) { $lang_actions{full} = 1; }
    if (-f $paradigmfiles{test} || -f $gen_norm_fst ) { $lang_actions{test} = 1; }
	}
	if (-f $gen_norm_fst) { $lang_actions{dialect} = 1; }
	else { $gen_norm_fst = $gen_fst; }
	if (-f $hfst_tokenize) { $has_tokenizer = 1 ;}


	if ($action eq "analyze" && ! -f $fst_without_semtags) { 
		http_die '--no-alert','404 Not Found',"$fst_without_semtags is not in the $lang/bin folder";
	}
	if ($action eq "disamb" && ! -f $dis_rle) { 
		http_die '--no-alert','404 Not Found',"The file $dis_rle is not found: Disambiguation is not supported";
	  #	if ($action eq "disamb" && ! -f $dis_bin) { 
	  #		http_die '--no-alert','404 Not Found',"disambiguator.cg3: Disambiguation is not supported";
	}
	if ($action eq "disamb" && ! -f $syn_rle) { 
		http_die '--no-alert','404 Not Found',"The file $syn_rle is not found: Syntactic function analysis is not supported";
	}
	if ($action eq "dependency" && ! -f $dep_rle) { 
		http_die '--no-alert','404 Not Found',"The file $dep_rle is not found: Dependency analysis is not supported";
	}
	if ($action eq "generate" && ! -f $gen_fst) {
		http_die '--no-alert','404 Not Found',"$gen_fst ($lang): Generation is not supported";
	}
	if ($action eq "hyphenate" && ! -f $hyph_fst) {
		http_die '--no-alert','404 Not Found',"$hyph_fst ($lang): Hyphenation is not supported";
	}
	if ($action eq "transcribe" && ! -f $phon_fst) {
		http_die '--no-alert','404 Not Found',"$phon_fst ($lang): Phonetic representation is not supported";
	}
	if ($action eq "convert" && ! -f $orth_fst) {
		http_die '--no-alert','404 Not Found',"$orth_fst ($lang): Orthographic representation is not supported";
	}
	if ($action eq "lat2syll" && ! -f $lat2syll_fst) {
		http_die '--no-alert','404 Not Found',"$lat2syll_fst ($lang): Conversion to syllabics is not supported";
	}
	if ($action eq "syll2lat" && ! -f $syll2lat_fst) {
		http_die '--no-alert','404 Not Found',"$syll2lat_fst ($lang): Conversion from syllabics is not supported";
	}
	if ($action eq "paradigm" && ! -f $gen_fst) {
		http_die '--no-alert','404 Not Found',"$gen_fst ($lang): Paradigm generation is not supported";
	}
	if ($tr_lang ne "none" && ( ! -f $translate_script && ! -f $translate_lex && -f $translate_fst ) ) { 
		http_die '--no-alert','404 Not Found', "Translation to language \"$tr_lang\" is not supported";
	}
	if (!$plang || ! $page_languages{$plang}) { $plang = "eng"; }

	# preprocess soon deprecated 6.1.22.
	if (-f "$fstdir/abbr.txt") {
		$preprocess = "$bindir/preprocess --abbr=$fstdir/abbr.txt";
	}
	else { $preprocess = "$bindir/preprocess"; }

	#	if ($lang eq "sme" && $action eq "analyze" ) {
	#	    $analyze = "$preprocess | $utilitydir/lookup $fstflags $fst_without_semtags";
	#	}

	# Doing this in two steps to use an analyser which gives output with pluses. 
	# Otherwise, analyzing e.g. alit oahppu is problematic
	if (($action eq "paradigm" || $action eq "analyze") && $has_tokenizer) {
    	$analyze = "$hfstutilitydir/hfst-tokenize $hfstflags $hfst_tokenize | $hfst_lookup $hfstflags $fst_without_semtags ";
    } elsif ($action eq "paradigm" || $action eq "analyze") {
	    $analyze = "$preprocess | $hfst_lookup $hfstflags $fst_without_semtags ";
    }
    
    
	#    $hfstanalyze = "$preprocess | $hfst_lookup $hfst";

	# if ... (4 languages with syn_rle) ... else the rest
	if (($lang eq "fao")||($lang eq "sma")||($lang eq "sme")||($lang eq "smj")||($lang eq "nob")) {
    $disamb = "$hfstutilitydir/hfst-tokenize -cg $hfst_tokenize | $bindir/vislcg3 -g $dis_rle | $bindir/vislcg3 -g $syn_rle "; 
    $dependency =  "$hfstutilitydir/hfst-tokenize -cg $hfst_tokenize | $bindir/vislcg3 -g $dis_rle | $bindir/vislcg3 -g $syn_rle | $bindir/vislcg3 -g $dep_rle";
    # old version, to be deleted when dust settles, 6.1.22
		# $disamb = "$preprocess | $utilitydir/lookup $fstflags $fst | $bindir/lookup2cg | $bindir/vislcg3 -g $dis_rle | $bindir/vislcg3 -g $syn_rle "; 
		# $dependency = "$preprocess | $utilitydir/lookup $fstflags $fst | $bindir/lookup2cg | $bindir/vislcg3 -g $dis_rle | $bindir/vislcg3 -g $syn_rle | $bindir/vislcg3 -g $dep_rle"; 
	}
	else { 
		$disamb = "$hfstutilitydir/hfst-tokenize -cg $hfst_tokenize | $bindir/vislcg3 -g $dis_rle ";  
		$dependency = "$hfstutilitydir/hfst-tokenize -cg $hfst_tokenize | $bindir/vislcg3 -g $dis_rle  | $bindir/vislcg3 -g $dep_rle "; 
  	}

	# for the next debug, this is the variable-free version of $dependency:
	# /usr/bin/preprocess --abbr=/opt/smi/sme/bin/abbr.txt | /usr/bin/lookup -flags mbTT -utf8 /opt/smi/sme/bin/analyser-gt-desc.xfst | /usr/bin/lookup2cg | /usr/bin/vislcg3 -g /opt/smi/sme/bin/disambiguator.cg3   | /usr/bin/vislcg3 -g /opt/smi/sme/bin/functions.cg3   | /usr/bin/vislcg3 -g /opt/smi/sme/bin/dependency.cg3 
	# /usr/bin/preprocess --abbr=/opt/smi/nob/bin/abbr.txt | /usr/bin/lookup -flags mbTT -utf8 /opt/smi/nob/bin/analyser-gt-desc.xfst | /usr/bin/lookup2cg | /usr/bin/vislcg3 -g /opt/smi/nob/bin/disambiguator.cg3   | /usr/bin/vislcg3 -g /opt/smi/nob/bin/functions.cg3   | /usr/bin/vislcg3 -g /opt/smi/nob/bin/dependency.cg3 

	$gen_lookup = "$hfst_lookup $hfstflags $gen_fst" ;
	$gen_norm_lookup = "$hfst_lookup $hfstflags $gen_norm_fst" ;
	$generate = "tr ' ' '\n' | $gen_lookup";
	$generate_norm = "tr ' ' '\n' | $gen_norm_lookup";
	$hyphenate = "$preprocess | $hfst_lookup $hfstflags $hyph_fst"; # | $commondir/hyph-filter.pl"; # this out
	#$hyphenate = "$preprocess | $utilitydir/lookup $fstflags $hyphrules_fst ";  # this in, until hyph-filter works
	$removeq = "sed \"s/\+//g ; s/\?//g\"";
	$transcribe = "$preprocess | $hfst_lookup $hfstflags $phon_fst";
	my $complextranscribe = "$preprocess | $hfst_lookup $hfstflags $num_fst | cut -f2 | $removeq | $hfst_lookup $hfstflags $hyph_fst | cut -f2 | $hfst_lookup $hfstflags $phon_fst" ;

	$placenames = "$hfst_lookup -q $geo_fst";

	if ($lang eq "sme") { $transcribe = $complextranscribe; }
  
	$convert = "$preprocess | $hfst_lookup $hfstflags $orth_fst";
	$lat2syll = "$preprocess | $hfst_lookup $hfstflags $lat2syll_fst";
	$syll2lat = "$preprocess | $hfst_lookup $hfstflags $syll2lat_fst";

	$remove_weight = "sed 's/	[0-9].*//g'";

    # File where the language is stored.
	$langfile="$commondir/cgi-$plang.xml";
}

1; 
