#!/usr/bin/python

import sgmllib, string

class StrippingParser(sgmllib.SGMLParser):
    
    from htmlentitydefs import entitydefs # replace entitydefs from sgmllib
    
    def __init__(self):
        sgmllib.SGMLParser.__init__(self)
        self.result = ""
        
    def handle_data(self, data):
        if data:
            self.result = self.result + data

    def handle_charref(self, name):
        self.result = "%s&#%s;" % (self.result, name)
        
    def handle_entityref(self, name):
        if self.entitydefs.has_key(name): 
            x = ';'
        else:
            # this breaks unstandard entities that end with ';'
            x = ''
        self.result = "%s&%s%s" % (self.result, name, x)
    
    def unknown_starttag(self, tag, attrs):
        pass

    def unknown_endtag(self, tag):
        pass
        
def strip(s):
    parser = StrippingParser()
    parser.feed(s)
    parser.close()
    return string.join(string.split(parser.result))
    
if __name__=='__main__':
    import sys
    print strip(open(sys.argv[1], "r").read())
