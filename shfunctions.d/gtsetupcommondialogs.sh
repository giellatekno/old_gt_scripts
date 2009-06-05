# -*-Shell-script-*-
# Common GT setup dialog elements.
# $Id:jmx-settings.sh 7231 2008-01-14 22:33:35Z wolfgang_m $

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
