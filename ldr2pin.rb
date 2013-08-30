#!/usr/bin/ruby
#
# ldr2pin.rb - Livedoor ReaderのPinをまとめてpinboard.inにブックマークするスクリプト
#

$KCODE='utf8'

require 'rubygems'
require 'net/netrc'
require 'mechanize'
require 'json'
require 'cgi'
require 'open-uri'
require 'kconv'

netrc_ldr = Net::Netrc.locate "ldr"
netrc_pin = Net::Netrc.locate "pinboard.in"

# login LDR
agent = Mechanize.new
page = agent.get('http://reader.livedoor.com/reader/')
form = page.form_with(:name => 'loginForm')
form.livedoor_id = netrc_ldr.login
form.password = netrc_ldr.password
agent.submit(form)

# get all pin
page = agent.post('http://reader.livedoor.com/api/pin/all')
pin = JSON::parse(page.body)

# post bookmarks to pinboard.in
#   http://pinboard.in/howto/#api (like delicious.com API)
post_url = 'https://api.pinboard.in/v1/posts/add'
post_error = false
pin.each{|p|
  link  = p['link']
  title = p['title'].toutf8
  puts "title=#{title}"
  puts "url  =#{link}"

  url = post_url + "?url=#{CGI.escape(link)}&description=#{CGI.escape(title)}"

  begin
    open(url, :http_basic_authentication=>[netrc_pin.login, netrc_pin.password]){|f|
      res = f.read
      unless res =~ /done/
        puts "==== POST ERROR ===="
        puts res

        post_error = true
        break
      end
    }
  rescue Exception => e
    puts "==== POST ERROR ===="
    pp e
    pp e.backtrace
    post_error = true
    break
  end
}

# clear all pin
unless post_error
  api_key = agent.cookie_jar.jar['reader.livedoor.com']['/']['reader_sid'].value
  agent.post('http://reader.livedoor.com/api/pin/clear', 'ApiKey' => api_key)
end
