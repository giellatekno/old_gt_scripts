(*
A script to run the spell checker in MS Word on the input file, using MS Word itself.

INPUT:
- ARGV #1: LANGUAGE code
- ARGV #2: input file
- ARGV #3: output file

The input file is expected to have one word on each line. It is possible that the script would work without this limitation, but that is not tested. Also, due to limitations in Word and in the speller, certain input strings are removed before being sent to Word (this is done in the Makefile). This includes strings containing spaces, full stops and hyphens.

Spaces in input string: these are considered separate words by the speller (and by MS Word), and can't be corrected by a spell checker. Thus, such cases are irrelevant for testing the spell checker.
Full stops and hyphens: MS Word treats these chars as word-breaking chars, which means that one can't reliably send such strings through the speller. There might be some way around this, but none found so far. If we could be sure to send the whole string to the speller, it would certainly be able to deal with them. For now it is best to remove such data.

OUTPUT:

A tab-separated file of the following scheme:
Orig	SpellerCategory	Suggestions

where:

Orig = the original string in the input file (ie the word to be spell-checked)
SpellerCategory = either one of:
	- SplCor (correct spelling according to the speller)
	- SplErr (spelling error according to the speller
	- CapErr (capitalization error, don't know exactly what this means)
Suggestions = list of suggestions given by the speller, potentially empty. The list is tab separated

This AppleScript file is best edited using Script Editor - it will give great help with syntax colouring & checking etc.
*)

on run argv
	-- we set up a reference to the indata file:
	set f1 to item 2 of argv -- input file
	set infile to POSIX file f1 -- infile is a file object again
	
	-- we set up a reference to the output file:
	set f2 to item 3 of argv -- output file
	set outfile to POSIX file f2 -- outfile is a file object again
	
	try
		set ufile to open for access outfile with write permission
	on error
		return "The file " & outfile & " could not be opened!"
	end try
	
	set testLang to item 1 of argv
	
	set savedTextItemDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {"	"}
	
	tell application "Microsoft Word"
		open infile
		set theDocument to active document
		set myRange to set range text object of active document start 0 end (end of content of text object of theDocument)
		if testLang is "sme" then
			set language ID of myRange to catalan -- due to bug in MS Office 2004
		else if testLang is "smj" then
			set language ID of myRange to basque -- due to bug in MS Office 2004
		else if testLang is "nob" then
			set language ID of myRange to norwegian bokmol
		else if testLang is "nno" then
			set language ID of myRange to norwegian nynorsk
		else if testLang is "swe" then
			set language ID of myRange to swedish
		else if testLang is "fin" then
			set language ID of myRange to finnish
		else if testLang is "isl" then
			set language ID of myRange to icelandic
		else if testLang is "dan" then
			set language ID of myRange to danish
		else if testLang is "eng" then
			set language ID of myRange to english uk
		else if testLang is "ger" then
			set language ID of myRange to german
		else if testLang is "deu" then
			set language ID of myRange to german
		end if
		-- The final EOF char is counted as a "word", thus the word count is actually one less
		set wc to (count of words of myRange) - 1
		
		repeat with i from 1 to wc
			set SugRec to text range spelling suggestions of word i of myRange
			set checkedWord to content of word i of myRange
			if type class of SugRec = spelling correct then
				set spellType to "SplCor"
			else if type class of SugRec = spelling not in dictionary then
				set spellType to "SplErr"
			else
				set spellType to "CapErr"
			end if
			set suggestions to list of SugRec
			tell me -- necessary to put the file-out commands in the domain of the script, and not of MS Word
				if (count of suggestions) = 0 then
					write checkedWord & "	" & spellType & "	" & "
" to ufile
				else
					set suggText to (suggestions as string)
					write checkedWord & "	" & spellType & "	" & suggText & "
" to ufile
				end if
			end tell
		end repeat
		close active document saving no
	end tell
	set AppleScript's text item delimiters to savedTextItemDelimiters
	close access ufile
end run
