#!/usr/bin/env ruby

# Migel::Util::Server -- migel -- 02.10.2012 -- yasaka@ywesee.com
# Migel::Util::Server -- migel -- 31.01.2012 -- mhatakeyama@ywesee.com

require "sbsm/app"
require "migel/util/importer"
require "odba/drbwrapper"
require "odba/18_19_loading_compatibility"
# another monkey patch for CSV
class CSV
  puts "Attention: monkey-patching CSV::Cell"
  # deprecated
  class Cell < String
    @@first = false
    def initialize(data = "", is_null = false)
      unless @@first
        warn "Attention: monkey-patching CSV::Cell used by #{caller.join('\n')}"
        @@first = true
      end
      super(is_null ? "" : data)
    end

    def data
      to_s
    end
  end
end

module Migel
  module Util
    class Server < SBSM::App
      def _admin(src, result, priority = 0)
        @admin_threads ||= ThreadGroup.new
        t = Thread.new {
          Thread.current.abort_on_exception = false
          begin
            response = instance_eval(src)
            str = response.to_s
            result << if str.length > 200
              response.class
            else
              str
            end.to_s
          rescue => error
            result << (error ? error.message : "no msg")
            if Migel.logger
              Migel.logger.error("admin") { error.class }
              Migel.logger.error("admin") { error.message }
              Migel.logger.error("admin") { error.backtrace.pretty_inspect }
            end
            error
          end
        }
        t[:source] = src
        t.priority = priority
        @admin_threads.add(t)
        t.join
      end

      def unpeer_cache cache
        ODBA.unpeer cache
      end

      def export_products(file_name = "/var/www/migel/data/csv/migel_all_products_de.csv", lang = "de")
        CSV.open(file_name, "w") do |writer|
          all_products.values.sort_by { |prod| prod.migel_code }.each do |product|
            writer << [
              product.migel_code,
              product.pharmacode,
              product.ean_code,
              product.article_name.send(lang),
              product.companyname.send(lang),
              product.companyean,
              product.ppha,
              product.ppub,
              product.factor,
              product.pzr,
              product.size.send(lang),
              product.status,
              product.datetime,
              product.stdate,
              product.language
            ]
          end
        end
      end

      def export_all_products
        export_products("/var/www/migel/data/csv/migel_all_products_de.csv", "de")
        export_products("/var/www/migel/data/csv/migel_all_products_fr.csv", "fr")
      end

      # The following methods are for search
      public

      def migelid_index_keys(lang, len = 1)
        lang = "de" unless lang.to_s == "de" or lang.to_s == "fr"
        ODBA.cache.index_keys("migel_model_migelid_name_#{lang}", len)
      end

      def group
        ODBA::DRbWrapper.new(Migel::Model::Group)
      end

      def subgroup
        ODBA::DRbWrapper.new(Migel::Model::Subgroup)
      end

      def migelid
        ODBA::DRbWrapper.new(Migel::Model::Migelid)
      end

      def product
        ODBA::DRbWrapper.new(Migel::Model::Product)
      end

      def search_migel_migelid(query, lang)
        # search order
        # 1. Group, Subgroup, Migelid name fulltext search
        # 2. Group, Subgroup, Migelid name prefix search
        if lang.to_s != "de" and lang.to_s != "fr"
          lang = "de"
        end
        search_migelid_by_name(query, lang)
      end

      def sort_select_products(products, sortvalue, reverse = nil)
        products = products.select do |product|
          !product.ean_code.nil? and product.status != "I"
        end.sort_by do |item|
          if sortvalue.to_sym == :ppub
            item.ppub.to_f
          else
            begin
              item.send(sortvalue).to_s
            rescue NoMethodError
            end
          end
        end
        if reverse
          products.reverse!
        end
        products
      end

      def search_migel_product_by_migel_code(migel_code, sortvalue = nil, reverse = nil)
        if migelid = Migel::Model::Migelid.search_by_migel_code(migel_code).first and products = migelid.products
          sortvalue ||= :pharmacode
          if products = sort_select_products(products, sortvalue, reverse)
            ODBA::DRbWrapper.new(products)
          end
        end
      end

      private

      def search_migelid_fulltext(query, lang)
        index_table_name = "migel_fulltext_index_" + lang
        result = ODBA.cache.retrieve_from_index(index_table_name, query)
        ODBA::DRbWrapper.new(result) unless result.empty?
      end

      def search_migelid_by_name(query, lang)
        search_method = "search_by_name_" + lang
        result = []
        if groups = Migel::Model::Group.send(search_method, query) and !groups.empty?
          groups.each do |group|
            result.concat group.subgroups.collect { |sg| sg.migelids }.flatten
          end
        end
        if subgroups = Migel::Model::Subgroup.send(search_method, query) and !subgroups.empty?
          result.concat subgroups.collect { |sg| sg.migelids }.flatten
        end
        result.concat Migel::Model::Migelid.send(search_method, query)
        ODBA::DRbWrapper.new(result.uniq)
      end

      public

      def search_migel_product(query, lang, sortvalue = nil, reverse = nil)
        # search product by fulltext search
        if lang.to_s != "de" and lang.to_s != "fr"
          lang = "de"
        end
        index_table_name = "migel_product_fulltext_index_" + lang
        result = ODBA.cache.retrieve_from_index(index_table_name, query)
        products = if result.empty?
          # search product by name (prefix search)
          search_method_article_name = "search_by_article_name_" + lang.downcase.to_s
          search_method_company_name = "search_by_company_name_" + lang.downcase.to_s
          result = Migel::Model::Product.send(search_method_article_name, query) + Migel::Model::Product.send(search_method_company_name, query)
          result
        else
          result
        end

        sortvalue ||= :pharmacode
        if products = sort_select_products(products, sortvalue, reverse)
          ODBA::DRbWrapper.new(products)
        end
      end

      def search_limitation(migel_code)
        case migel_code.length
        when 2 # Group
          if group = Migel::Model::Group.find_by_migel_code(migel_code)
            ODBA::DRbWrapper.new(group.limitation_text)
          end
        when 5 # Subgroup
          if subgroup = Migel::Model::Subgroup.find_by_migel_code(migel_code)
            ODBA::DRbWrapper.new(subgroup.limitation_text)
          end
        else # Migelid
          if migelid = Migel::Model::Migelid.find_by_migel_code(migel_code)
            ODBA::DRbWrapper.new(migelid.limitation_text)
          end
        end
      end

      # The following methods are for initial setup
      public

      def init_fulltext_index_tables
        puts "#{Time.now}:Starting init_fulltext_index_tables. init_migelids"
        init_migelids
        puts "#{Time.now}: ..init_products"
        init_products
        puts "#{Time.now}: ..rebuild_fulltext_index_tables"
        rebuild_fulltext_index_tables
        puts "#{Time.now}:Finished init_fulltext_index_tables"
      end

      def init_migelids
        clear_migelids
        ODBA.cache.index_keys("migel_model_migelid_migel_code").each do |migel_code|
          migelids.store(migel_code, Migel::Model::Migelid.find_by_migel_code(migel_code))
        end
        migelids.odba_store
      end

      def migelids
        @migelids ||= ODBA.cache.fetch_named("all_migelids", self) {
          {}
        }
      end
      alias_method :all_migelids, :migelids
      def clear_migelids
        migelids.clear
        migelids.odba_store
      end

      def init_products(estimate = false)
        clear_products
        pharmacode_list = ODBA.cache.index_keys("migel_model_product_pharmacode")
        total = pharmacode_list.length
        start_time = Time.now
        pharmacode_list.each_with_index do |pharmacode, i|
          products.store(pharmacode, Migel::Model::Product.find_by_pharmacode(pharmacode))
          puts estimate_time(start_time, total, i + 1) if estimate
        end
        products.odba_store
      end

      def products
        @products ||= ODBA.cache.fetch_named("all_products", self) {
          {}
        }
      end
      alias_method :all_products, :products
      def clear_products
        products.clear
        products.odba_store
      end

      def rebuild_fulltext_index_table(yaml_index_definition)
        index_name = yaml_index_definition.index_name
        begin
          ODBA.cache.drop_index(index_name)
        rescue
          # do nothing
        end
        ODBA.cache.create_index(yaml_index_definition, Migel)
        source = instance_eval(yaml_index_definition.init_source)
        ODBA.cache.fill_index(index_name, source)
      end

      def rebuild_fulltext_index_tables
        # migel_fulltext_index_de
        # migel_fulltext_index_fr
        # migel_product_fulltext_index_de
        # migel_product_fulltext_index_fr
        index_definition_migel_de = YAML.load <<~EOD
          --- !ruby/object:ODBA::IndexDefinition
          index_name: 'migel_fulltext_index_de'
          origin_klass: 'Migel::Model::Migelid'
          target_klass: 'Migel::Model::Migelid'
          resolve_search_term: 'full_description(:de)'
          resolve_target: ''
          resolve_origin: ''
          fulltext: true
          init_source: 'all_migelids.values'
        EOD

        index_definition_migel_fr = YAML.load <<~EOD
          --- !ruby/object:ODBA::IndexDefinition
          index_name: 'migel_fulltext_index_fr'
          origin_klass: 'Migel::Model::Migelid'
          target_klass: 'Migel::Model::Migelid'
          resolve_search_term: 'full_description(:fr)'
          resolve_target: ''
          resolve_origin: ''
          fulltext: true
          init_source: 'all_migelids.values'
        EOD

        index_definition_migel_product_de = YAML.load <<~EOD
          --- !ruby/object:ODBA::IndexDefinition
          index_name: 'migel_product_fulltext_index_de'
          origin_klass: 'Migel::Model::Product'
          target_klass: 'Migel::Model::Product'
          resolve_search_term: 'full_description(:de)'
          resolve_target: ''
          resolve_origin: ''
          fulltext: true
          init_source: 'all_products.values'
        EOD

        index_definition_migel_product_fr = YAML.load <<~EOD
          --- !ruby/object:ODBA::IndexDefinition
          index_name: 'migel_product_fulltext_index_fr'
          origin_klass: 'Migel::Model::Product'
          target_klass: 'Migel::Model::Product'
          resolve_search_term: 'full_description(:fr)'
          resolve_target: ''
          resolve_origin: ''
          fulltext: true
          init_source: 'all_products.values'
        EOD
        rebuild_fulltext_index_table(index_definition_migel_de)
        rebuild_fulltext_index_table(index_definition_migel_fr)
        rebuild_fulltext_index_table(index_definition_migel_product_de)
        rebuild_fulltext_index_table(index_definition_migel_product_fr)
      end
    end
  end
end
