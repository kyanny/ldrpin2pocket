#!/usr/bin/ruby

require 'mechanize'
require 'json'
require 'cgi'
require 'open-uri'

class LDR
  def initialize(livedoor_id, password)
    @livedoor_id = livedoor_id
    @password = password
  end

  def login
    @agent ||= Mechanize.new
    page = @agent.get('http://reader.livedoor.com/reader/')
    form = page.form_with(name: 'loginForm')
    form.livedoor_id = @livedoor_id
    form.password = @password
    @agent.submit(form)
  end

  def get_all_pins
    page = @agent.post('http://reader.livedoor.com/api/pin/all')
    @pins = JSON.parse(page.body)
  end

  def clear_all_pins
    unless post_error
      api_key = @agent.cookie_jar.jar['reader.livedoor.com']['/']['reader_sid'].value
      @agent.post('http://reader.livedoor.com/api/pin/clear', 'ApiKey' => api_key)
    end
  end

  def each_pin(&block)
    @pins.each do |pin|
      yield(pin) if block_given?
    end
  end
end

class Pocket
  def add(url)
    p url
  end
end

@pocket = Pocket.new

@ldr = LDR.new(ENV['LIVEDOOR_ID'], ENV['LIVEDOOR_PASSWORD'])
@ldr.login
@ldr.get_all_pins
@ldr.each_pin do |pin|
  p pin
  p['link']
  p['title']
  p['title'].encoding
  CGI.escape(p['link'])
  CGI.escape(p['title'])

  @pocket.add(p['link'])
end
