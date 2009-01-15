#!/usr/bin/env python
# -*- coding: utf-8 -*
"""
File   iptocountry.py

Version 0.0.2  Jan. 15, 2009  Packaged the functionality in to a class (Børre Gaup <borre.gaup@samediggi.no>)
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



class ipToCountry:
	def __init__(self):
		self.COUNTRYDBASE = "/home/boerre/.ipcountrycodes"  #simple pickled dictionary really!
		self.countrycodesDict =  {}
		if os.path.exists(self.COUNTRYDBASE):
			f = open(self.COUNTRYDBASE,"r")
			self.countrycodesDict =  pickle.load(f)
			f.close()

			
	
		
	def __del__(self):
		"""
		Writes back the countrycodes dictionary.
		"""
		f = open(self.COUNTRYDBASE,"wb")
		pickle.dump(self.countrycodesDict, f)
		f.close()
		

	def getCountrycode(self, IPAddress):
		"""
		Returns a countrycode for the IP (numeric) address.
		
		Warning:
			Assumes your are on a Linux server with a whois server.
			Otherwise, function will simply return None for all arguments.
		"""
		if IPAddress in self.countrycodesDict:
			#print "@@@dbg:[%s] already in dictionary!" % IPAddress
			return self.countrycodesDict[IPAddress]
			
		status, output = commands.getstatusoutput("whois -h whois.lacnic.net %s " %IPAddress)
		try:
			if status== 0:
				print output
				startpos = output.find("country")
				if startpos == -1:
					startpos = output.find("Country")
				if startpos >= 0:		    
					#print "@@@dbg: startpos= ", startpos
					endpos   = startpos + output[startpos:].find("\n")
					#print "@@@dbg: endpos = ", startpos+endpos 
					line = output[startpos: endpos]
					#print "@@@dbg: line = ", line
					country = line.split()[1]
					self.countrycodesDict[IPAddress] = country
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
	iptoC = ipToCountry()

	# Do your querying...
	for ip in ["122.2.172.47","209.131.36.158", "129.242.4.42", "82.147.49.206" ]:
		print iptoC.getCountrycode(ip)

            

if __name__ == "__main__":
	main()