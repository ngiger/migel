#!/usr/bin/env ruby
# frozen_string_literal: true

# Migel::Model::Product -- migel -- 18.98.2011 -- mhatakeyama@ywesee.com

require "migel/model/product"
require "migel/persistence/odba/model_super"

module Migel
  module Model
    class Product < ModelSuper
      odba_index :pharmacode
      odba_index :ean_code
      # odba_index :article_name
      odba_index :article_name_de, "article_name.de"
      odba_index :article_name_fr, "article_name.fr"
      # odba_index :companyname
      # odba_index :companyname_de, 'companyname.de'
      # odba_index :companyname_fr, 'companyname.fr'
      odba_index :company_name_de, "companyname.de"
      odba_index :company_name_fr, "companyname.fr"
    end
  end
end
