#!/usr/bin/env ruby

# Migel::Model::Subgroup -- migel -- 29.08.2011 -- mhatakeyama@ywesee.com

require "migel/model/subgroup"
require "migel/persistence/odba/model_super"

module Migel
  module Model
    class Subgroup < ModelSuper
      odba_index :code
      odba_index :migel_code
      odba_index :name_de, "name.de"
      odba_index :name_fr, "name.fr"
      # odba_index :name
    end
  end
end
