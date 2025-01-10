#!/usr/bin/env ruby
# frozen_string_literal: true

# Migel::Model::Group -- migel -- 29.08.2011 -- mhatakeyama@ywesee.com

require 'migel/model/group'
require 'migel/persistence/odba/model_super'

module Migel
  module Model
    class Group < ModelSuper
      odba_index :code
      odba_index :migel_code
      # odba_index :name
      odba_index :name_de, 'name.de'
      odba_index :name_fr, 'name.fr'
    end
  end
end
