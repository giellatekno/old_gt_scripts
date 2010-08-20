#!/bin/sh
#
# 'unsoort' taken from:
# http://wiki.tcl.tk/13817
#
# It is useful to randomise lines of texts, e.g. to anonymise speller test
# input for licensed gold-standard texts - when the input (ie words) is
# randomised, it is impossible to reconstruct the original text, and for
# speller testing the value of the data is still exactly the same.
#
# The next line restarts with tclsh.\
exec tclsh "$0" ${1+"$@"}

proc main {} {
    set lines [lrange [split [read stdin] \n] 0 end-1]
    set count [llength $lines]

   for {} {$count>1} {incr count -1} {
        set idx_1 [expr {$count-1}]
        set idx_2 [expr {int($count * rand())}]
        set temp [lindex $lines $idx_1]
        lset lines $idx_1 [lindex $lines $idx_2]
        lset lines $idx_2 $temp
    }

    puts [join $lines \n]
}

main
