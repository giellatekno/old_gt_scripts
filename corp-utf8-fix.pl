#!/usr/bin/perl

my $string = ;

if ($string =~ /[èÈ¼©]/){
  print "if\n";
  while (<$string>){
    print "if-while\n";
    s/¹/đ/g;
	s/©/Đ/g;
	s/è/č/g;
	s/È/Č/g;
	s/¼/ž/g;
	s/¿/ŋ/g;
	s/º/š/g;
  }
}
else {
  print "else\n";
  while (<$string>){
    print "else-while\n";
    s/„/č/g;
	s/˜/đ/g;
	s/¿/ž/g;
	s/ð/đ/g;
	s/‚/Č/g;
	s/¹/ŋ/g;
	s/ð/đ/g;
	s/‰/Đ/g;
	
	s/ð/đ/g;
	s/ç/č/g;
	s/Ç/Č/g;
	s/Ó/Š/g;
	s/ó/š/g;
	s/þ/ž/g;
	s/ñ/ŋ/g;
	s/Ñ/Ŋ/g;
	s/ý/ŧ/g;
	
	s/²/Š/g;
	s/³/š/g;
	s/¢/č/g;
	s/¡/Č/g;
	s/±/ŋ/g;
	s/ð/đ/g;
	s/ç/č/g;
	s/º/ž/g;
	s/¤/đ/g;
  }
}

print $string;
