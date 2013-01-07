# -*- coding: utf-8 -*-
import sys
import re

ctypes = [
    
    # mac-sami converted as iconv -f mac -t utf8
    # 0
    {
        "ª": "š",
        "¥": "Š",
        "º": "ŧ",
        "µ": "Ŧ",
        "∫": "ŋ",
        "±": "Ŋ",
        "¸": "Ŋ",
        "π": "đ",
        "∞": "Đ",
        "Ω": "ž",
        "∑": "Ž",
        "∏": "č",
        "¢": "Č"
    },
    
    # iso-ir-197 converted as iconv -f mac -t utf8
    # 1
    {
        "·": "á",
        "¡": "Á",
        "≥": "š",
        "≤": "Š",
        "∏": "ŧ",
        "µ": "Ŧ",
        "±": "ŋ",
        "Ø": "Ŋ",
        "§": "đ",
        "£": "Đ",
        "∫": "ž",
        "π": "Ž",
        "¢": "č",
        "°": "Č",
        "Ê": "æ",
        "Δ": "Æ",
        "¯": "ø",
        "ÿ": "Ø",
        "Â": "å",
        "≈": "Å",
        "‰": "ä",
        "ƒ": "Ä",
        "ˆ": "ö",
        "÷": "Ö",
    },
    
    # 2
    {
        "ƒ": "š",    #
        "√": "ŋ",    #
        "∂": "đ",    #
        "π": "ž",    #
        "ª": "č",    #
        "º": "Č",    #
    },
    
    # winsami2 converted as iconv -f latin1 -t utf8
    # 3
    {
        "\xc2\x9a": "š",
        "\xc2\x8a": "Š",
        "¼": "ŧ",
        "º": "Ŧ",
        "¹": "ŋ",
        "¸": "Ŋ",
        "": "đ",
        "": "Đ",
        "¿": "ž",
        "¾": "Ž",
        "": "č",
        "": "Č",
    },
    
    # iso-ir-197 converted as iconv -f latin1 -t utf8
    # 4
    {
        "³": "š",
        "²": "Š",
        "¸": "ŧ",
        "µ": "Ŧ",
        "±": "ŋ",
        "¯": "Ŋ",
        "¤": "đ",
        "£": "Đ",
        "º": "ž",
        "¹": "Ž",
        "¢": "č",
        "¡": "Č",
    },
    
    # mac-sami to latin1
    # 5
    {
        "": "á",
        "‡": "á",
        "ç": "Á",
        "»": "š",
        "´": "Š",
        "¼": "ŧ",
        "µ": "Ŧ",
        "º": "ŋ",
        "±": "Ŋ",
        "¹": "đ",
        "°": "Đ",
        "½": "ž",
        "·": "Ž",
        "¸": "č",
        "¢": "Č",
        "¾": "æ",
        "®": "Æ",
        "¿": "ø",
        "¯": "Ø",
        "": "å",
        "": "é",
        "Œ": "å",
        "": "Å",
        "": "ä",
        "": "Ä",
        "": "ö",
        "": "Ö",
        "Ê": " ",
        "¤": "§",
        "Ò": "“",
        "Ó": "”",
        "ª ": "™ ",
        "ªÓ": "™”",
        "Ã": "√",
        "Ð": "–",
        #"Ç": "«",
        #"È": "»",
    },
    
    # found in boundcorpus/goldstandard/orig/sme/facta/GIEHTAGIRJI.correct.doc
    # and boundcorpus/goldstandard/orig/sme/facta/learerhefte_-_vaatmarksfugler.doc
    # 6
    {
        "ð": "đ",
        "Ç": "Č",
        "ç": "č",
        "ó": "š",
        "ý": "ŧ",
        "þ": "ž",
    },

    # found in freecorpus/orig/sme/admin/sd/other_files/dc_00_1.doc
    # and freecorpus/orig/sme/admin/guovda/KS_02.12.99.doc
    # found in boundcorpus/orig/sme/bible/other_files/vitkan.pdf
    # latin4 as latin1
    # 7
    {
        "ð": "đ",
        "È": "Č",
        "è": "č",
        "¹": "š",
        "¿": "ŋ",
        "¾": "ž",
        "¼": "ŧ",
        "‚": "Č",
        "„": "č",
        #"¹": "ŋ",
        "˜": "đ",
        #"¿": "ž",
    },

    # 8
    {
        "t1": "ŧ",
        "T1": "Ŧ",
        "s1": "š",
        "S1": "Š",
        "n1": "ŋ",
        "N1": "Ŋ",
        "d1": "đ",
        "D1": "Đ",
        "z1": "ž",
        "Z1": "Ž",
        "c1": "č",
        "C1": "Č",
        "ï¾«": "«",
        "ï¾»": "»",
    }
]

limits = { 0: 1, 1: 1, 2: 3, 3: 3, 4: 3, 5: 3, 6: 1, 7: 1, 8: 3}

import unittest

class TestEncodingGuesser(unittest.TestCase):
    def testEncodingGuesser(self):
        eg = EncodingGuesser()
        for i in range(0, len(ctypes)):
            self.assertEqual(eg.guessFileEncoding('parallelize_data/decode-' + str(i) + '.txt'), i)

    def testRoundTripping(self):
        eg = EncodingGuesser()
        
        f = open('parallelize_data/decode-utf8.txt')
        utf8_content = f.read()
        f.close()
        
        for i in range(0, len(ctypes)):
            f = open('parallelize_data/decode-' + str(i) + '.txt')
            content = f.read()
            f.close()
            
            test_content = eg.decodePara(i, content)
            
            self.assertEqual(utf8_content, test_content)
        
class EncodingGuesser:
    def guessFileEncoding(self, filename):
        
        f = open(filename)
        content = f.read()
        f.close()
        winner = self.guessBodyEncoding(content)
        
        return winner
        
    def guessBodyEncoding(self, content):
        
        maxhits = 0
        winner = -1
        for position in range(0, len(ctypes)):
            hits = 0
            num = 0
            for key in ctypes[position].viewkeys():
                
                #print len(re.compile(key).findall(content)), key
                if len(re.compile(key).findall(content)) > 0:
                    num = num + 1
                    
                hits = hits + len(re.compile(key).findall(content))
                
            #print "position", position, "hits", hits, "num", num
            
            if hits > maxhits and limits[position] < num:
                winner = position
                maxhits = hits
                #print "winner", winner, "maxhits", maxhits
            
        #print "the winner is", winner
        return winner
        
    def guessPersonEncoding(self, person):
        
        f = open(filename)
        content = f.read()
        content = content.lower()
        f.close()
        
        maxhits = 0
        for position in range(0, len(ctypes)):
            hits = 0
            num = 0
            for key in ctypes[position].viewkeys():
                
                #print len(re.compile(key).findall(content)), key
                if len(re.compile(key).findall(content)) > 0:
                    num = num + 1
                    
                hits = hits + len(re.compile(key).findall(content))
                
            #print "position", position, "hits", hits, "num", num
            
            
            if hits > maxhits:
                winner = position
                maxhits = hits
                #print "winner", winner, "maxhits", maxhits
                
            # 8 always wins over 5 as long as there are any hits for 8
            if winner == 5 and num > 1:
                winner = 8
            
        #print "the winner is", winner
        return winner
        
    def decodePara(self, position, text):
        encoding = ctypes[position]
        
        for key, value in encoding.items():
            text = text.replace(key, value)
        
        if position == 5:
            text = text.replace("Ç", "«")
            text = text.replace("È", "»")

        return text

if __name__ == '__main__':
    import sys
    eg = EncodingGuesser()
    print eg.guessFileEncoding(sys.argv[1])
    