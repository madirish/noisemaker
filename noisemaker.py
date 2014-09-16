#!/usr/bin/python

from HTMLParser import HTMLParser
from urllib2 import Request, urlopen, URLError, HTTPError
        
import os
import random
import linecache
import syslog
        
class googleLinks(HTMLParser):

  links = []
  searchword = ""
  
  def __init__(self, word):
	#print "Looking up word: " + word
	HTMLParser.__init__(self)
        self.searchword = word
	urlstring = "http://www.google.com/search?q=" + str(word).rstrip()
	urlstring += "&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:unofficial&client=firefox-a"
	#print urlstring
	try:
	  request = Request(url=urlstring)
	  request.add_header("User-Agent", "FooBrowser 2.3")
	  
	  req = urlopen(request)	
	  self.feed(req.read())
	  #self.parseLinks()
	except URLError as e:
		#print "Error opening " + url + " " + e.reason
		pass
			
  def handle_starttag(self, tag, attrs):
	if tag == 'a' and attrs:
	  if attrs[0][1][7:11] == 'http':
		linkurl = attrs[0][1][7:]
		if linkurl.find("google") < 0:
		  self.links.append(linkurl)
		  
  def printLinks(self):
	  for link in self.links:
		  print "Link is: " + link + "\n"

  def spiderRandomLink(self):
    linkslen = len(self.links)
	  #print "There are " + str(linkslen) + " links"
    if linkslen > 1:
      randomLinkNum = random.randint(1, linkslen) - 1
      urltopull = self.links[randomLinkNum]
      request = Request(url=urltopull)
      randomAgent = self.randomAgentString()
      request.add_header("User-Agent", randomAgent)
      syslog.syslog(syslog.LOG_INFO, "Noisemakering " + str(urltopull))
    else:
      syslog.syslog(syslog.LOG_INFO, "Noisemaker didn't find any links for " + self.searchword)
    try:
      urlopen(request)
    except:
      pass
	  
  def randomAgentString(self):
	  agents = ["FooBrowser 2.3", 
				"<script>alert('xss browser');</script>", 
				"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322; FDM)",
				"Mozilla/6.0; (Spoofed by Amiga-AWeb/3.5.07 beta)",
        "Mozilla/3.0 (compatible; MSIE 5.0; Windows NT 4.1; Trident/2.0)",
        "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Trident/3.0)",
        "Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/3.0)",
        "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)",
        "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",
        "Mozilla/5.0 (Linux; U; Android 3.0; en-us; sdk Build/HONEYCOMB) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13",
        "Mozilla/5.0 (Linux; U; Android 4.0.3; en-us; google_sdk Build/MR1) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
        "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; GTB7.4; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; BRI/2; .NET4.0C; .NET4.0E; McAfee)",
        "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:20.0) Gecko/20100101 Firefox/8.0",
        "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:20.0) Gecko/20100101 Firefox/19.0",
        "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:20.0) Gecko/20100101 Firefox/20.0",
        "Mozilla/5.0 (iPad; U; CPU OS 3_2_1 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Mobile/7B405",
        "Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B367 Safari/531.21.10",
				"Mozilla/5.0 (X11; CrOS armv7l 2913.260.0) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.99 Safari/537.11"]
	  return agents[random.randint(1, len(agents)-1)]
                          
class getWord:
  wordfile = "/usr/share/dict/linux.words"
  
  def __init__(self):
	  wordcount = self.getCount()
	  randwordnum = random.randint(1, int(wordcount))
	  self.randword = linecache.getline(self.wordfile, randwordnum)
	  
  def getWord(self):
	  return self.randword
	  
  def getCount(self):
	with open(self.wordfile) as wordfile:
		for i, l in enumerate(wordfile):
			pass
	return i+1
		
word = getWord()
seeker = googleLinks(word.getWord())
seeker.spiderRandomLink()
