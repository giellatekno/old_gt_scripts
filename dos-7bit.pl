#!/usr/bin/perl -w

# This script is for dos to internal conversion. It is taylored to translate
# Pekka Sammallahti's source code (dictionaries and name lists) to the internal
# representation. 


while (<>) 
{

    s/�/a/g ;   # This a with dot below is not represented in the twol system

# convert the 7 sami letters from dos to 7bit format
    s/�/�/g ; 
    s/�/�/g ; 
    s/�/C1/g ; 
    s/�/c1/g ; 
#   s//D1/g ;   # D1, N1, T1, Z1 were not found in the source, and are not
    s/�/d1/g ;  # included in this conversion script. 
#   s//N1/g ;   # TODO: Get the value of these letters, and include them.
    s/�/n1/g ; 
    s/�/S1/g ; 
    s/\201/s1/g ;
#   s//T1/g ; 
    s/�/t1/g ;
#   s//Z1/g ;
    s/�/z1/g ;

# convert special vowels and consonants
    s/�/e1/g ; 
    s/�/o1/g ; 
    s/�/h1/g ;
    s/�/i1/g ;
    s/�/o/g ;    # This is long o, it is not accounted for. (cf. ohkoladdat+V)
    s/�/e/g ;    # This is long e, it is not accounted for in the source.
    s/�/u/g ;    # This is long u, it is not accounted for in the source.
    s/�//g ;  # This is the Finnish silent glottal in words like venex.

# Convert scandinavian vowels
    s/�/�/g ;
    s/�/�/g ;
    s/�/�/g ;    # Capital � missing
    s/�/�/g ;    # Capital � missing
    s/�/�/g ;
    s/�/�/g ;
    s/�/�/g ;
    s/�/�/g ;

# Other symbols
    s/�/'/g ; # The mark for 3rd grade.
    s///g ;    # removing hyphens in the source.

print ;
}
