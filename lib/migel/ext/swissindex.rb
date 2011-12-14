#!/usr/bin/ruby
# encoding: utf-8
# ODDB::Swissindex::SwissindexPharma -- 01.11.2011 -- mhatakeyama@ywesee.com

require 'rubygems'
require 'savon'
require 'mechanize'
require 'drb'
require 'odba/18_19_loading_compatibility'

module ODDB
  module Swissindex
    def Swissindex.session(type = SwissindexPharma)
      yield(type.new)
    end

class SwissindexNonpharma
  URI = 'druby://localhost:50002'
  include DRb::DRbUndumped
  def initialize
    Savon.configure do |config|
        config.log = false            # disable logging
        config.log_level = :info      # changing the log level
    end
    @base_url   = 'https://prod.ws.e-mediat.net/wv_getMigel/wv_getMigel.aspx?Lang=DE&Query='
  end
  def search_item(pharmacode, lang = 'DE')
    lang.upcase!
    client = Savon::Client.new do | wsdl, http |
      wsdl.document = "https://index.ws.e-mediat.net/Swissindex/NonPharma/ws_NonPharma_V101.asmx?WSDL"
    end
    try_time = 3
    begin
      response = client.request :get_by_pharmacode do
        soap.xml = '<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
              <pharmacode xmlns="http://swissindex.e-mediat.net/SwissindexNonPharma_out_V101">' + pharmacode + '</pharmacode>
              <lang xmlns="http://swissindex.e-mediat.net/SwissindexNonPharma_out_V101">' + lang + '</lang>
          </soap:Body>
        </soap:Envelope>'
      end
      if nonpharma = response.to_hash[:nonpharma]
        nonpharma_item = if nonpharma[:item].is_a?(Array)
                           nonpharma[:item].sort_by{|item| item[:gtin].to_i}.reverse.first
                         elsif nonpharma[:item].is_a?(Hash)
                           nonpharma[:item]
                         end
if nonpharma_item
if nonpharma_item[:pharmacode]
print "nonpharma_item[:pharmacode] = "
p nonpharma_item[:pharmacode]
end
if nonpharma_item[:datetime]
print "nonpharma_item[:datetime] = "
p nonpharma_item[:datetime].strftime("%Y.%m.%d")
end
if nonpharma_item[:stdate]
print "nonpharma_item[:stdate] = "
p nonpharma_item[:stdate].strftime("%Y.%m.%d")
end
puts
end
        return nonpharma_item
      else
        return nil
      end

    rescue StandardError, Timeout::Error => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        try_time -= 1
        retry
      else
        puts " - probably server is not responding"
        puts err
        puts err.backtrace
        puts
        return nil
      end
    end
  end
  def search_migel(pharmacode, lang = 'DE')
    agent = Mechanize.new
    try_time = 3
    begin
      agent.get(@base_url.gsub(/DE/, lang) + 'Pharmacode=' + pharmacode)
      count = 100
      line = []
      agent.page.search('td').each_with_index do |td, i|
        text = td.inner_text.chomp.strip
        if text.is_a?(String) && text.length == 7 && text == pharmacode
          count = 0
        end
        if count < 7
          text = text.split(/\n/)[1] || text.split(/\n/)[0]
          text = text.gsub(/\302\240/, '').strip if text
          line << text
          count += 1
        end
      end
      line
    rescue StandardError, Timeout::Error => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        agent = Mechanize.new
        try_time -= 1
        retry
      else
        return []
      end
    end
  end
  def merge_swissindex_migel(swissindex_item, migel_line)
    # Swissindex data
    swissindex = swissindex_item.collect do |key, value|
      case key
      when :gtin
        [:ean_code, value]
      when :dt
        [:datetime, value]
      when :lang
        [:language, value]
      when :dscr
        [:article_name, value]
      when :addscr
        [:size, value]
      when :comp
        [:companyname, value[:name], :companyean, value[:gln]]
      else
        [key, value]
      end
    end
    swissindex = Hash[*swissindex.flatten]

    # Migel data
    pharmacode, article_name, companyname, ppha, ppub, factor, pzr = *migel_line
    migel = {
      :pharmacode   => pharmacode,
      :article_name => article_name,
      :companyname  => companyname,
      :ppha         => ppha,
      :ppub         => ppub,
      :factor       => factor,
      :pzr          => pzr,
    }
    migel.update swissindex
  end
  def search_migel_table(code, query_key = 'Pharmacode', lang = 'DE')
    # 'MiGelCode' is also available for query_key
    agent = Mechanize.new
    try_time = 3
    begin
      agent.get(@base_url.gsub(/DE/,lang) + query_key + '=' + code)
      count = 100
      table = []
      line  = []
      migel = {}
      agent.page.search('td').each_with_index do |td, i|
        text = td.inner_text.chomp.strip
        if text.is_a?(String) && text.length == 7 && text.match(/\d{7}/) 
          migel_item = if pharmacode = line[0] and pharmacode.match(/\d{7}/) and swissindex_item = search_item(pharmacode, lang)
                         merge_swissindex_migel(swissindex_item, line)
                       else
                         merge_swissindex_migel({}, line)
                       end
          table << migel_item
          line = []
          count = 0
        end
        if count < 7 
          text = text.split(/\n/)[1] || text.split(/\n/)[0]
          text = text.gsub(/\302\240/, '').strip if text
          line << text
          count += 1
        end
      end

      # for the last line
      migel_item = if pharmacode = line[0] and pharmacode.match(/\d{7}/) and swissindex_item = search_item(pharmacode, lang)
                     merge_swissindex_migel(swissindex_item, line)
                   else
                     merge_swissindex_migel({}, line)
                   end
      table << migel_item
      table.shift
=begin
if table
print "table.first[:pharmacode] = "
p table.first[:pharmacode]
print "table.first[:datetime] = "
p table.first[:datetime].strftime("%Y.%m.%d")
puts
end
=end
      table
    rescue StandardError, Timeout::Error => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        agent = Mechanize.new
        try_time -= 1
        retry
      else
        return []
      end
    end
  end
  def search_item_with_swissindex_migel(pharmacode, lang = 'DE')
    migel_line = search_migel(pharmacode, lang)
    if swissindex_item = search_item(pharmacode, lang)
      merge_swissindex_migel(swissindex_item, migel_line)
    else
      merge_swissindex_migel({}, migel_line)
    end
  end
  def search_migel_position_number(pharmacode, lang = 'DE')
    agent = Mechanize.new
    try_time = 3
    begin
      agent.get(@base_url.gsub(/DE/, lang) + 'Pharmacode=' + pharmacode)
      pos_num = nil
      agent.page.search('td').each_with_index do |td, i|
        if i == 6
          pos_num = td.inner_text.chomp.strip
          break
        end
      end
      return pos_num
    rescue StandardError, Timeout::Error => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        agent = Mechanize.new
        try_time -= 1
        retry
      else
        return nil
      end
    end
  end
end


class SwissindexPharma
  URI = 'druby://localhost:50001'
  include DRb::DRbUndumped
  def initialize
    Savon.configure do |config|
        config.log = false            # disable logging
        config.log_level = :info      # changing the log level
    end
  end
  def search_item(code, search_type = :get_by_gtin, lang = 'DE')
    client = Savon::Client.new do | wsdl, http |
      wsdl.document = "https://index.ws.e-mediat.net/Swissindex/Pharma/ws_Pharma_V101.asmx?WSDL"
    end
    try_time = 3
    begin
      response = client.request search_type do
      soap.xml = if search_type == :get_by_gtin
      '<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <GTIN xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + code + '</GTIN>
          <lang xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + lang    + '</lang>
        </soap:Body>
      </soap:Envelope>'
                 elsif search_type == :get_by_pharmacode
      '<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <pharmacode xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + code + '</pharmacode>
          <lang xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + lang    + '</lang>
        </soap:Body>
      </soap:Envelope>'
                 end
      end
      if pharma = response.to_hash[:pharma] 
        # If there are some products those phamarcode is same, then the return value become an Array
        # We take one of them which has a higher Ean-Code
        pharma_item = if pharma[:item].is_a?(Array)
                        pharma[:item].sort_by{|item| item[:gtin].to_i}.reverse.first
                      elsif pharma[:item].is_a?(Hash)
                        pharma[:item]
                      end
        return pharma_item
      else
        return nil
      end

    rescue StandardError, Timeout::Error => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        try_time -= 1
        retry
      else
        puts " - probably server is not responding"
        puts err
        puts err.backtrace
        puts
        return nil
      end
    end
  end
end

  end # Swissindex
end # ODDB
