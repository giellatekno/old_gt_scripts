# -*-Shell-script-*-
# Common GT setup dialog elements.
# $Id$

msg_title () {
    echo ---------------------------------------
    echo Setting up your Giellatekno environment
    echo ---------------------------------------
}

msg_create () {
    echo I will create a file named $RC in your
    echo home directory, containing the lines:
    echo
    case $ONCONSOLE in
        YES)
    echo \\\"$SOURCECMD\\\"
    ;;
        NO)
    echo "   \"$SOURCECMD\""
    ;;
    esac
}

msg_append () {
    echo I will append the lines:
    echo
    case $ONCONSOLE in 
	YES)
    echo \\\"$SOURCECMD\\\"
    ;;
	NO)
    echo "   \"$SOURCECMD\""
    ;;
    esac
    echo
    echo to the file $RC in your home directory.
}		       

display_result () {
# display final result
    case $ONCONSOLE in
        YES)
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n$Result\n" buttons {"OK"} default button 1 with icon caution giving up after 20
      set UserResponse to button returned of dd
      return ""
   end tell
EOF
   ;;
	NO)
   printf "$Result" 
   ;;
    esac
}

msg_already_setup (){
    echo Your environment seems to be correctly
    echo set up for Giellatekno already.
}

msg_main_only_setup (){
    echo Your environment seems to be correctly
    echo set up for the main part of Giellatekno.
    echo However, you seem to be missing some optional
    echo parts.
}

msg_main_big_setup (){
    echo Your environment seems to be correctly
    echo set up for the public part of Giellatekno.
    echo
    echo There is also a private repository for
    echo people employed on the projects. This
    echo repository is not needed for most tasks,
    echo but it does contain some closed code
    echo required for making the MS Office proofing tools.
    echo
    echo If you know you need this, and have a
    echo user name and password giving you access
    echo to the private repository, then click continue.
    echo Otherwise just skip this part, and you
    echo are done.
}

display_already_setup (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_already_setup`" buttons {"OK"} default button 1 giving up after 20 
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_already_setup
    ;;
    esac
}

display_main_big_setup (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_main_big_setup`" buttons {"Skip", "Continue"} default button 1 giving up after 60 
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_main_big_setup
    /bin/echo -n " [S/c] "
    read answer
    answer=`echo $answer | sed 's/^[sS].*$/n/'`
    if [ ! -z "$answer" -a "x$answer" != "xs" ]; then
       answer="Continue"
    fi
    ;;
    esac
}
