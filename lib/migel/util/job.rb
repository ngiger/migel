#! /usr/bin/env ruby
# frozen_string_literal: true

# Migel::Util::Job -- migel -- 06.01.2012 -- mhatakeyama@ywesee.com

require 'drb'
require 'migel/config'
require 'migel/util/server'
require 'migel/model'
require 'migel/persistence/odba'
$stdout.sync = true
$stderr.sync = true

module Migel
  module Util
    module Job
      def self.run(opts = {}, &block)
        system = DRb::DRbObject.new(nil, Migel.config.server_url)
        DRb.start_service
        begin
          ODBA.cache.setup
          ODBA.cache.clean_prefetched
          DRb.install_id_conv ODBA::DRbIdConv.new
          begin
            system.peer_cache ODBA.cache unless opts[:readonly]
          rescue StandardError
            Errno::ECONNREFUSED
          end
          block.call Migel::Util::Server.new
        ensure
          system.unpeer_cache ODBA.cache unless opts[:readonly]
        end
      end
    end
  end
end
