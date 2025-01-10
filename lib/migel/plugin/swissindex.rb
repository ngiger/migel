#!/usr/bin/env ruby

# Migel::SwissindexMigelPlugin -- migel -- 10.04.2012 -- yasaka@ywesee.com
# Migel::Util::Swissindex          -- migel -- 07.09.2011 -- mhatakeyama@ywesee.com

require "migel/ext/swissindex" # for dRuby
require "migel/ext/refdata" # for dRuby
require "migel/model"
require "migel/util/logger"

module ODDB
  module Swissindex
    class SwissindexMigel; end
  end
end

module Migel
  class SwissindexMigelPlugin
    attr_reader :migel_codes_with_products, :migel_codes_without_products
    SWISSINDEX_MIGEL_URI = "druby://localhost:50002"
    SWISSINDEX_MIGEL_SERVER = DRbObject.new(nil, SWISSINDEX_MIGEL_URI)
    include Migel::Util
    def initialize(migel_codes)
      @migel_codes = migel_codes
    end

    def get_migelid_by_migel_code(migel_code, lang = "de")
      Migel::Model::Migelid.find_by_migel_code(migel_code)
    end

    def save_all_products(file_name = "migel_products_de.csv", lang = "de", estimate = false)
      Migel.debug_msg "save_all_products #{file_name}. lang #{lang} #{@migel_codes.size} codes"
      @saved_products = 0
      @migel_codes_with_products = []
      @migel_codes_without_products = []
      lang = lang.upcase
      start_time = Time.now
      total = @migel_codes.length
      CSV.open(file_name, "w:utf-8") do |writer|
        SWISSINDEX_MIGEL_SERVER.session(ODDB::Swissindex::SwissindexMigel) do |swissindex|
          @migel_codes.each_with_index do |migel_code, count|
            Migel.debug_msg "save_all_products migel_code #{migel_code} count #{count} Migel::DebugMigel #{Migel::DebugMigel}"
            # break if /2/.match(migel_code) and Migel::DebugMigel
            product_flag = false
            if migelid = get_migelid_by_migel_code(migel_code)
              migel_code = migelid.migel_code.split(".").join
              table = swissindex.search_migel_table(migel_code, "MiGelCode", lang)
              if table.empty?
                Migel.debug_msg "search_migel_table returned table.empty? for migel_code #{migel_code} lang #{lang}"
              else
                products = table.select { |record| record[:pharmacode] and record[:article_name] }
                Migel.debug_msg "search_migel_table returned for #{migel_code} #{products.size} products"
                products.each do |record|
                  Migel.debug_msg "save_all_products 2: migel_code #{migel_code} record #{record}"
                  writer << [
                    migel_code,
                    record[:pharmacode],
                    record[:ean_code],
                    record[:article_name],
                    record[:companyname],
                    record[:companyean],
                    record[:ppha],
                    record[:ppub],
                    record[:factor],
                    record[:pzr],
                    record[:size],
                    record[:status],
                    record[:datetime],
                    record[:stdate],
                    record[:language]
                  ]
                  @saved_products += 1
                  product_flag = true
                end
              end
            end
            Migel.debug_msg "#{Time.now}:migel_code #{migel_code} product_flag #{product_flag}"
            if product_flag
              @migel_codes_with_products << migel_code
            else
              @migel_codes_without_products << migel_code
            end
            time = estimate_time(start_time, total, count + 1)
            puts time if estimate
          end
        end # SWISSINDEX_MIGEL_SERVER
        Migel.debug_msg "save_all_products done"
      end # CSV.open
      [
        @saved_products,
        @migel_codes_with_products,
        @migel_codes_without_products
      ]
    end
  end
end
