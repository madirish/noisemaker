#!/usr/bin/ruby

require 'open-uri'

def initialize_database(location='/usr/share/dict/linux.words')
  words = Array.new
  if not File.exist?(location)
    return false
  else
    File.open(location).each do |word|
      words.push(word)
    end
  end
  return words
end

words = initialize_database()
print "Words has #{words.count}\n"
randword = words[rand(words.count)].strip
print "Random word is #{randword}\n"

requrl = "http://www.google.com/search?q=#{randword}&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:unofficial&client=firefox-a"
response = open(requrl, 'User-Agent' => 'RandomBrowser').read
puts response