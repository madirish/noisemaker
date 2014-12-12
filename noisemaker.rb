#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

def initialize_database(location)
  words = Array.new
  # Bail out if we don't have a working file
  return false if not File.exist?(location)
  File.open(location).each do |word|
    words.push(word)
  end
  return words
end

def randomagentstring() 
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
   return agents[rand(agents.count)]
end

def cleanlink(link)
  return (link && link[0..3] == 'http') ? link : false;
end

def parselinks(links)
  linkstospider = Array.new
  links.each do |link|
    #puts link
    if link["href"] then
      # There seem to be two formats for links from Google that we're interested in
      {'?url=http'=>'?url=', 'url?q=http'=>'url?q='}.each do |urlstring,splitstring|
        if (link["href"].index(urlstring)) 
          addlink = link["href"].split(splitstring)[1]
          #puts "Got #{addlink}"
          linkstospider.push(addlink) if addlink && cleanlink(addlink) 
        end
      end
    end
    
  end
  # If we didn't get any Google tracked type results, parse regular links
  if linkstospider.count < 1
    #puts "No Google tracked redirects, using old school links"
    links.each do |link|
      #puts "Examining #{link['href']}"
      if link["href"] && link["href"].index('google') == nil
        linkstospider.push(link["href"]) if cleanlink(link["href"]) 
      end
    end
  end
  #puts "\nParsed to:"
  #linkstospider.each do |slink|
  #  puts slink
  #end
  return linkstospider.count > 0 ? linkstospider[rand(linkstospider.count)] : ''
end

linuxwords = '/usr/share/dict/linux.words'
macwords = '/usr/share/dict/words'

location = (true && File.exists?(linuxwords)) || macwords

words = initialize_database(location)
randword = words[rand(words.count)].strip
print "Random word is #{randword}\n"

requrl = "https://www.google.com/search?q=#{randword}&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:unofficial&client=firefox-a"
response = Nokogiri::HTML(open(requrl, 'User-Agent' => randomagentstring).read)
links = response.css("a")
randlink = parselinks(links)
if randlink == ''
  abort('No links')
end

randagent = randomagentstring
puts "Spidering #{randlink} as #{randagent}"
begin
  spideresponse = open(randlink, 'User-Agent' => randagent)
rescue OpenURI::HTTPError => error
  spideresponse = error.io
end
puts "Got #{spideresponse.status[0]}"

