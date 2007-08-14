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

	#supported languages and tools
	my %languages = (sme => {analyze => 1, disamb => 1, hyphenate => 1, generate => 1, paradigm => 1},
					 smj => {analyze => 1, disamb => 1, hyphenate => 1, generate => 1, paradigm => 1},
					 sma => {analyze => 1, generate => 1, paradigm => 1},
					 kal => {analyze => 1, disamb => 1, hyphenate => 1, generate => 1},
					 foe => {analyze => 1, disamb => 1, hyphenate => 1, generate => 1}
					 ipk => {analyze => 1, disamb => 1, hyphenate => 1, generate => 1}
					 );

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

	if (! $languages{$lang}) { http_die '--no-alert','404 Not Found',"The language \"$lang\" is not available."; }
	if (! $languages{$lang}{$action}){ http_die '--no-alert','404 Not Found',"The tool \"$action\" is not available for $lang."; }
	if ($pos && ! $avail_pos{$pos}) { http_die '--no-alert','404 Not Found',"The word class \"$pos\" is not available."; }
	if (!$plang || ! $page_languages{$plang}) { $plang = "eng"; }
	
	$wordlimit = 250 ;       # adjust as appropriate; prevent large-scale use
	
    # System-Specific directories
    # The directory where utilities like 'lookup' are stored
	my $utilitydir = "/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin";
    # The directory for vislcg and lookup2cg
	my $bindir = "/opt/sami/cg/bin/";

    # The fst's and other tools
	my $optdir = "/opt/smi";
	my $commondir = "/opt/smi/common/bin";
	my $fstdir = "$optdir/$lang/bin" ;

    # Files to generate paradigm
	if ($action eq "paradigm") {
		$paradigmfile="/opt/smi/common/bin/paradigm.txt";
		%paradigmfiles = (
						  minimal => "$commondir/paradigm_min.txt",
						  standard => "$commondir/paradigm_standard.txt",
						  full => "$commondir/paradigm_full.txt",
						  dialect => "$commondir/paradigm_full.txt",
						  );
		
		$paradigmfile=$paradigmfiles{$mode};
	}
	my $tmpdir = "/tmp";
	$tmpfile=$tmpdir . "/smi-test2.txt";
	my $time = `date +%m-%d-%H-%M`;
	chomp $time;
	$logfile = $tmpdir . "/cgi-" . $time . ".log";
	
	
	$tagfile="$optdir/$lang/bin/korpustags.$lang.txt";
	if (! -f $tagfile) { $tagfile="$commondir/korpustags.txt"; }
	
	my $fst = "$fstdir/$lang.fst";
    my $gen_fst = "$fstdir/i$lang.fst";
    my $gen_norm_fst = "$fstdir/i$lang-norm.fst";
	my $hyph_fst = "$fstdir/hyph-$lang.fst";
    my $fstflags = "-flags mbTT -utf8";
    my $dis_rle = "$fstdir/$lang-dis.rle";

	if ($action eq "disamb" && ! -f $dis_rle) { 
		http_die '--no-alert','404 Not Found',"$dis_rle: Disambiguation is not supported";
	}
	if ($action eq "gen" && ! -f $gen_fst) {
		http_die '--no-alert','404 Not Found',"$gen_fst: Generation is not supported";
	}
	if ($action eq "gen" && ! -f $hyph_fst) {
		http_die '--no-alert','404 Not Found',"$hyph_fst: Hyphenation is not supported";
	}

    $preprocess = "$bindir/preprocess --abbr=$fstdir/abbr.txt";
    $analyze = "$preprocess | $utilitydir/lookup $fstflags $fst";
	$disamb = "$analyze | $bindir/lookup2cg | $bindir/vislcg --grammar=$dis_rle"; 
	$gen_lookup = "$utilitydir/lookup $fstflags -d $gen_fst" ;
	$gen_norm_lookup = "$utilitydir/lookup $fstflags -d $gen_norm_fst" ;
    $generate = "tr ' ' '\n' | $gen_lookup";
    $generate_norm = "tr ' ' '\n' | $gen_norm_lookup";
    $hyphenate = "$preprocess | $utilitydir/lookup $fstflags $hyph_fst | $commondir/hyph-filter.pl";

    # File where the language is stored.
	$langfile="$commondir/cgi-$plang.xml";
}

1; 
