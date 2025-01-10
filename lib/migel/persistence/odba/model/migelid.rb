#!/usr/bin/env ruby

# Migel::Model::Migelid -- migel -- 18.98.2011 -- mhatakeyama@ywesee.com

require "migel/model/migelid"
require "migel/persistence/odba/model_super"
require "migel/util/multilingual"

module Migel
  module Model
    class Migelid < ModelSuper
      # odba_index :code, :codes, {:type => 'type.to_s', :country => 'country', :value => 'to_s'}
      odba_index :code
      odba_index :migel_code
      # odba_index :migel_code, :name
      # odba_index :name, 'name.de'
      odba_index :name_de, "name.de"
      odba_index :name_fr, "name.fr"
      # odba_index :full_description_de, 'full_description(:de)'
      # odba_index :full_description_fr, 'full_description(:fr)'
    end
  end
end
