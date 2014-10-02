#!/usr/bin/env python
# -*- coding: utf-8 -*
"""
File   iptocountry.py

Version 0.0.2  Jan. 15, 2009  Packaged the functionality in to
a class (Børre Gaup <borre.gaup@uit.no>)
Version 0.0.1  Oct. 19, 2008  Basic function.

Author Ernesto P. Adorio, Ph.D.
       UP Extension Program in Pampanga
       Clark Field, Pampanga

E-mail ernesto.adorio@gmail.com

Desc   Given a list of numeric address, get the domain name
       and country.

License AGPL (See file COPYING in the download directory)

Copyright (C) 2008, Ernesto P. Adorio
Copyright (C) 2009, Børre Gaup

"""
import commands
import pickle
import os


class IPToCountry:
    def __init__(self):
        #simple pickled dictionary really!
        self.COUNTRYDBASE = os.path.expanduser('~') + "/.ipcountrycodes"
        self.countrycodes_dict = {}
        if os.path.exists(self.COUNTRYDBASE):
            f = open(self.COUNTRYDBASE, "r")
            self.countrycodes_dict = pickle.load(f)
            f.close()

    def __del__(self):
        """
        Writes back the countrycodes dictionary.
        """
        f = open(self.COUNTRYDBASE, "wb")
        pickle.dump(self.countrycodes_dict, f)
        f.close()

    def get_countrycode(self, ip_address):
        """
        Returns a countrycode for the IP (numeric) address.

        Warning:
            Assumes your are on a Linux server with a whois server.
            Otherwise, function will simply return None for all arguments.
        """
        if ip_address in self.countrycodes_dict:
            return self.countrycodes_dict[ip_address]

        status, output = commands.getstatusoutput(
            "whois -h whois.lacnic.net %s " % ip_address)
        try:
            if status == 0:
                startpos = output.find("country")
                if startpos == -1:
                    startpos = output.find("Country")
                if startpos >= 0:
                    endpos = startpos + output[startpos:].find("\n")
                    line = output[startpos: endpos]
                    country = line.split()[1]
                    self.countrycodes_dict[ip_address] = country
                else:
                    country = "N/A"
            else:
                country = "N/A"

        except:
            country = "N/A"
        return country


def main():
    # Here is how to use it.
    # First instantiate the class.
    iptoC = IPToCountry()

    # Do your querying...
    for ip in ["122.2.172.47", "209.131.36.158", "129.242.4.42",
               "82.147.49.206"]:
        print iptoC.get_countrycode(ip)


if __name__ == "__main__":
    main()
