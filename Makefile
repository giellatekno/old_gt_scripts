# This is a makefile that builds regex files.
# They are used by lookup to convert to and from
# various sámi encodings to the databases internal format

# "make all" will build .fst files for use
# with the lookup application
# ********************************************************

7bit-latin6.fst: 7bit-latin6.regex
	@echo
	@echo "*** 7bit-latin6.fst ***" ;
	@echo
	@printf "read regex < 7bit-latin6.regex \n\
	save stack 7bit-latin6.fst \n\
	quit \n" > /tmp/caseconv-script
	@xfst < /tmp/caseconv-script
	@rm -f /tmp/caseconv-script



7bit-linmac.fst: 7bit-linmac.regex
	@echo
	@echo "*** Building 7bit-linmac.fst ***" ;
	@echo
	@printf "read regex < 7bit-linmac.regex \n\
	save stack 7bit-linmac.fst \n\
	quit \n" > /tmp/caseconv-script
	@xfst < /tmp/caseconv-script
	@rm -f /tmp/caseconv-script


7bit-utf8.fst: 7bit-utf8.regex
	@echo
	@echo "*** Building 7bit-utf8.fst ***" ;
	@echo
	@printf "read regex < 7bit-utf8.regex \n\
	save stack 7bit-utf8.fst \n\
	quit \n" > /tmp/caseconv-script
	@xfst < /tmp/caseconv-script
	@rm -f /tmp/caseconv-script


7bit-ws2.fst: 7bit-ws2.regex
	@echo
	@echo "*** Building 7bit-ws2.fst ***" ;
	@echo
	@printf "read regex < 7bit-ws2.regex \n\
	save stack 7bit-ws2.fst \n\
	quit \n" > /tmp/caseconv-script
	@xfst < /tmp/caseconv-script
	@rm -f /tmp/caseconv-script


latin6-7bit.fst: latin6-7bit.regex
	@echo
	@echo "*** Building latin6-7bit.fst ***" ;
	@echo
	@printf "read regex < latin6-7bit.regex \n\
	save stack latin6-7bit.fst \n\
	quit \n" > /tmp/caseconv-script
	@xfst < /tmp/caseconv-script
	@rm -f /tmp/caseconv-script


linmac-7bit.fst: linmac-7bit.regex
	@echo
	@echo "*** Building linmac-7bit.fst ***" ;
	@echo
	@printf "read regex < linmac-7bit.regex \n\
	save stack linmac-7bit.fst \n\
	quit \n" > /tmp/caseconv-script
	@xfst < /tmp/caseconv-script
	@rm -f /tmp/caseconv-script


utf8-7bit.fst: utf8-7bit.regex
	@echo
	@echo "*** Building utf8-7bit.fst ***" ;
	@echo
	@printf "read regex < utf8-7bit.regex \n\
	save stack utf8-7bit.fst \n\
	quit \n" > /tmp/caseconv-script
	@xfst < /tmp/caseconv-script
	@rm -f /tmp/caseconv-script


ws2-7bit.fst: ws2-7bit.regex
	@echo
	@echo "*** Building ws2-7bit.fst ***" ;
	@echo
	@printf "read regex < ws2-7bit.regex \n\
	save stack ws2-7bit.fst \n\
	quit \n" > /tmp/caseconv-script
	@xfst < /tmp/caseconv-script
	@rm -f /tmp/caseconv-script


all:	ws2-7bit.fst 7bit-latin6.fst 7bit-linmac.fst \
	7bit-utf8.fst 7bit-ws2.fst latin6-7bit.fst \
	linmac-7bit.fst utf8-7bit.fst

clean:
	@rm -f *.fst


# ##############################################################


