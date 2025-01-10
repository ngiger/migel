#!/usr/bin/ruby
# frozen_string_literal: true

# ODDB::Swissindex::SwissindexPharma -- 10.04.2012 -- yasaka@ywesee.com
# ODDB::Swissindex::SwissindexPharma -- 01.11.2011 -- mhatakeyama@ywesee.com

require "rubygems"
require "savon"
require "mechanize"
require "drb"
require "odba/18_19_loading_compatibility"

module ODDB
  module Swissindex
    def self.session(type = SwissindexPharma)
      yield(type.new)
    end

    # definition only
    class SwissindexMigel
      URI = "druby://localhost:50002"
      include DRb::DRbUndumped
    end
  end
end
