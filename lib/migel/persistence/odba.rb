#!/usr/bin/env ruby

# Migel::Persistence::ODBA -- migel -- 17.08.2011 -- mhatakeyama@ywesee.com

require "migel/config"
require "odba"
require "odba/connection_pool"
require "odba/drbwrapper"

require "migel/persistence/odba/model/group"
require "migel/persistence/odba/model/subgroup"
require "migel/persistence/odba/model/migelid"
require "migel/persistence/odba/model/product"

module Migel
  module Persistence
    module ODBA
    end
  end
  ODBA.storage.dbi = ODBA::ConnectionPool.new("DBI:Pg:#{@config.db_name}", @config.db_user, @config.db_auth)
  ODBA.cache.setup
end
