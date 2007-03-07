(*
A script to run the spell checker in MS Word on the input file, using MS Word itself.

INPUT:
- ARGV #1: LANGUAGE code
- ARGV #2: input file

The input file is expected to have one word on each line. It is possible that the script would work without this limitation, but that is not tested.

OUTPUT:

A tab-separated file of the following scheme:
Orig	SpellerCategory	Suggestions

where:

Orig = the original string in the input file (ie the word to be spell-checked)
SpellerCategory = either one of:
	- SplCor (correct spelling according to the speller)
	- SplErr (spelling error according to the speller
	- CapErr (capitalization error, don't know exactly what this means)
Suggestions = list of suggestions given by the speller, potentially empty

This file is best edited using Script Editor - it will give great help with syntax colouring & checking etc.
*)

on run argv
	set the scriptpath to the path to me as string
	set {TID, text item delimiters} to {text item delimiters, ":"}
	set gtmappe to scriptpath's text items's items 1 thru -3 as string
	set text item delimiters to TID
	
	set x to POSIX path of the gtmappe -- common parent folder = the gt/ dir
	set f1 to item 2 of argv -- input file
	set p1 to x & "/" & f1 -- concat the gt/ dir and the input file
	set infile to POSIX file p1 -- infile is a file object again
	
	set testLang to item 1 of argv
	
	tell application "Microsoft Word"
		open infile
		set theDocument to active document
		set myRange to set range text object of active document start 0 end (end of content of text object of theDocument)
		if testLang is "sme" then
			set language ID of myRange to catalan
		else if testLang is "smj" then
			set language ID of myRange to basque
		end if
		set wc to count of words of myRange
		
		-- AppleScript needs(?) to collect all results in a variable, and then return
		-- everything at once at the end. Here we define the variable:
		set resultstring to ""
		
		repeat with i from 1 to wc - 1 by 2
			-- Word does for some reason count linebreaks as words,
			-- thus we skip every other "word", ie every linebreak
			-- This assumes that the text begins on line one, and that the
			-- first real word is "word" 1 in the MS Word sense.
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
			if (count of suggestions) = 0 then
				set resultstring to resultstring & checkedWord & "	" & spellType & "	" & "
"
			else
				set savedTextItemDelimiters to AppleScript's text item delimiters
				set AppleScript's text item delimiters to {", "}
				set suggText to (suggestions as string)
				set AppleScript's text item delimiters to savedTextItemDelimiters
				set resultstring to resultstring & checkedWord & "	" & spellType & "	" & suggText & "
"
			end if
		end repeat
		-- Here we return all the results in one big string:
		return resultstring
	end tell
end run
