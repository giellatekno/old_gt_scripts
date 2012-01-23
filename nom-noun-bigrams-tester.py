#!/usr/bin/env python
# -*- coding: utf-8 -*-
import unittest
import os
import subprocess

class TestConversion(unittest.TestCase):
    """Class to test output of Thomas/Linda words
    """
    def getPreprocessResult(self, expression):
        """
        Run an expression through nom-noun-bigrams.pl, return the answer 
        including return value
        """
        proc = subprocess.Popen(['nom-noun-bigrams.pl'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        result = proc.communicate(expression)
        
        return result[0]
    
    def testInput(self):
        """Test the input and output of the program
        """
        test_cases = {}
        test_cases["Kurssain\tkursa+N+Sg+Com\nKurssain\tkursa+N+Pl+Loc\n\nleat\tleat+V+IV+Ind+Prs+Sg2\nleat\tleat+V+IV+Ind+Prs+Pl3\nleat\tleat+V+IV+Ind+Prs+Pl1\nleat\tleat+V+IV+Ind+Prs+ConNeg\nleat\tleat+V+IV+Inf\n\námmát\támmát+N+Sg+Nom\n\nbagadallit\tbagadit+V+TV+Der/alla+V+Imprt+Pl2\nbagadallit\tbagadit+V+TV+Der/alla+V+Actor+N+Pl+Nom\nbagadallit\tbagadallat+V+TV+Imprt+Pl2\nbagadallit\tbagadallat+V+TV+Actor+N+Pl+Nom\nbagadallit\tbagadalli+Hum+N+Actor+Pl+Nom\n"] =  "ámmát bagadallit\n"
        test_cases["Illudan\tilludit+V+IV+PrfPrc\nIlludan\tilludit+V+IV+Ind+Prs+Sg1\nIlludan\tilludit+V+IV+Actio+Nom\nIlludan\tilludit+V+IV+Actio+Gen\nIlludan\tilludit+V+IV+Actio+Acc\nIlludan\tilludit+V+IV+Der/eapmi+N+Sg+Gen\n\ndakkár\tdakkár+Pron+Dem+Attr\ndakkár\tdakkár+Pron+Dem+Sg+Nom\n\neará\teará+Pron+Indef+Attr\neará\teará+Pron+Indef+Sg+Nom\neará\teará+Pron+Indef+Sg+Acc\neará\teará+Pron+Indef+Sg+Gen\n\nstudeanta\tstudeanta+Hum+N+Sg+Nom\n\nhommáide\thommá+N+Pl+Ill\nhommáide\thommát+V+IV+Ind+Prt+Du2\n\n.\t.+CLB\n"] = "studeanta hommáide\n"
        test_cases["Ná\tná+Adv\n\nmii\tmii+Pron+Rel+Sg+Nom\nmii\tmii+Pron+Interr+Sg+Nom\nmii\tmun+Pron+Pers+Pl1+Nom\n\noažžut\toažžut+V+TV+Inf\noažžut\toažžut+V+TV+Imprt+Pl2\noažžut\toažžut+V+TV+Imprt+Pl1\noažžut\toažžut+V+TV+Ind+Prs+Pl1\noažžut\toažžut+V+TV+Actor+N+Pl+Nom\n\nsámi\tsápmi+N+Sg+Gen\nsámi\tsápmi+N+Sg+Acc\n\nja\tja+CC\n\nálgoálbmot\tálgu+N+SgNomCmp+Cmp#álbmot+Hum+Group+N+Sg+Nom\nálgoálbmot\tálgu+N+SgNomCmp+Cmp#álbmot+Hum+Group+N+Sg+Gen\nálgoálbmot\tálgu+N+SgNomCmp+Cmp#álbmot+Hum+Group+N+Sg+Acc\nálgoálbmot\tálgu+N+SgNomCmp+Cmp#álbmut+V+TV+Actor+N+Sg+Nom+PxSg2\nálgoálbmot\tálgu+N+SgNomCmp+Cmp#álbmut+V+TV+Actor+N+Sg+Gen+PxSg2\nálgoálbmot\tálgu+N+SgNomCmp+Cmp#álbmut+V+TV+Actor+N+Sg+Acc+PxSg2\nálgoálbmot\tálgo#álbmot+Hum+Group+N+Sg+Nom\nálgoálbmot\tálgo#álbmot+Hum+Group+N+Sg+Gen\nálgoálbmot\tálgo#álbmot+Hum+Group+N+Sg+Acc\n\nperspektiivva\tperspektiiva+N+Sg+Gen\nperspektiivva\tperspektiiva+N+Sg+Acc\n\nbuot\tbuot+Adv\nbuot\tbuot+Pron+Indef\n\noahpahusas\toahpahus+N+Sg+Gen+PxSg3\noahpahusas\
toahpahus+N+Sg+Acc+PxSg3\noahpahusas\toahpahus+N+Sg+Loc\n\n.\t.+CLB\n"] = "álgoálbmot perspektiivva\n"
        
        for test_expression, want_expression in test_cases.iteritems():
            result_expression = self.getPreprocessResult(test_expression)
            self.assertEqual(result_expression, want_expression)
    
if __name__ == "__main__":
   unittest.main()
