#!/usr/bin/ruby

require 'mechanize'
require 'net/https'
require 'json'
require 'uri'

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
    api_key = @agent.cookie_jar.jar['reader.livedoor.com']['/']['reader_sid'].value
    @agent.post('http://reader.livedoor.com/api/pin/clear', 'ApiKey' => api_key)
  end

  def each_pin(&block)
    @pins.each do |pin|
      yield(pin) if block_given?
    end
  end
end

class Pocket
  def initialize(consumer_key, access_token)
    @consumer_key = consumer_key
    @access_token = access_token
  end

  def add(url)
    Net::HTTP.post_form(URI('https://getpocket.com/v3/add'), params(url: url))
  end

  def params(params)
    { consumer_key: @consumer_key, access_token: @access_token }.dup.merge(params)
  end
end

results = []

@pocket = Pocket.new(ENV['CONSUMER_KEY'], ENV['ACCESS_TOKEN'])

@ldr = LDR.new(ENV['LIVEDOOR_ID'], ENV['LIVEDOOR_PASSWORD'])
@ldr.login
@ldr.get_all_pins
@ldr.each_pin do |pin|
  res = @pocket.add(pin['link'])
  results << (res.code.to_i == 200)
end

@ldr.clear_all_pins if results.all?
