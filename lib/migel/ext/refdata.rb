#!/usr/bin/ruby
# frozen_string_literal: true

require 'rubygems'
require 'savon'
require 'mechanize'
require 'drb'
require 'odba/18_19_loading_compatibility'

module ODDB
  module Refdata
    def self.session(type = Refdata)
      yield(type.new)
    end

    # definition only
    class RefdataArticle
      URI = 'druby://localhost:50001'
      include DRb::DRbUndumped
    end
  end
end
