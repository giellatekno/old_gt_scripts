display_choose_priv_do () {
# propose to check out priv:
    case $ONCONSOLE in
        YES)
	    answer=`display_choose_priv`
	    ;;
		NO)
	    display_choose_priv
	    ;;
	esac
	if [ "$answer" == "YES" ]; then
	svnco=`cd "$GTPARENT" && svn co https://victorio.uit.no/biggies/trunk big`
	link_biggies
		if [ svnco == 0 ] ; then
		    Result="\n The Biggies part of the Giellatekno resources \
have been checked out in $GTPARENT/big.\n\
\n\
I also added symbolic links within each language dir to corpus \
resources for testing purposes."
		else
		    Result="\n
Something went wrong when checking out the biggies
repository. Please try to run this command manually:\n
\n
cd "$GTPARENT" && svn co https://victorio.uit.no/biggies/trunk big\n
\n"
		fi		    
    else
		Result="OK, as you wish.\nYou are on your own. Good luck\n" 
    fi
    display_result
}

