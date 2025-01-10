#!/usr/bin/env ruby
# frozen_string_literal: true

# Importer for CSV from Bauerfeind AG

require "csv"
require "fileutils"
require "zlib"
require "migel/util/mail"
require "spreadsheet"
require "open-uri"
require "migel/util/server"
require "migel/util/importer"
require "migel/model/group"

module Migel
  include Migel::Util
  module Util
    class CsvImporter
      STATUS_CSV_ITEMS = "A"
      Companyname_DE = "Bauerfeind AG" # rubocop:disable Naming/ConstantName
      Companyname_FR = "Bauerfeind SA" # rubocop:disable Naming/ConstantName
      attr_reader :data_dir, :csv_file

      def initialize
        $stdout.sync = true
        @nr_updated = 0
        @nr_ignored = 0
        @nr_records = 0
        @nr_products_before = 0
        @nr_products_after = 0
        @migel_codes_with_products = []
        @migel_codes_without_products = []
      end

      def report(lang = "de")
        lang = lang.downcase
        end_time = Time.now - @start_time
        @update_time = (end_time / 60.0).to_i
        res = [
          "Total time to update: #{format("%.2f", @update_time)} [m]",
          format("found via %s or %s were. Active products before/now: %d/%d", Companyname_DE, Companyname_FR,
            @nr_products_before - @nr_products_after, get_nr_active_bauerfeind_products),
          "Read CSV-file: #{@csv_file}",
          format("Total %5i Migelids (%5i Migelids have products / %5i Migelids have no products)",
            @nr_records,
            @migel_codes_with_products ? @migel_codes_with_products.length : 0,
            @migel_codes_without_products ? @migel_codes_without_products.length : 0),
          "Saved #{@saved_products} Products"
        ]
        res += [
          "",
          "Migelids with products (#{@migel_codes_with_products ? @migel_codes_with_products.length : 0})"
        ]
        if @migel_codes_with_products
          res += @migel_codes_with_products.sort.uniq.map do |migel_code|
            "http://ch.oddb.org/#{lang}/gcc/migel_search/migel_product/#{migel_code}"
          end
        end
        res += [
          "",
          "Migelids without products (#{@migel_codes_without_products ? @migel_codes_without_products.length : 0})"
        ]
        if @migel_codes_without_products && !@migel_codes_without_products.empty?
          res[-1] += @migel_codes_without_products.sort.uniq.map do |migel_code|
            "http://ch.oddb.org/#{lang}/gcc/migel_search/migel_product/#{migel_code}"
          end.to_s
        end
        subject = res[0]
        Migel::Util::Mail.notify_admins_attached(subject, res, nil)
        res
      end

      def import_all_products_from_csv(options)
        @start_time = Time.now
        puts "#{Time.now}: import_all_products_from_csv: options are #{options}"
        file_name = options[:filename]
        puts "#{Time.now}: import_all_products_file_name are #{file_name.inspect}"
        file_name = "/var/www/migel/data/csv/update_migel_bauerfeind.csv" unless file_name && !file_name.empty?
        unless File.exist?(file_name)
          puts "#{Time.now}: Unable to open #{file_name}"
          return false
        end
        lang = (options[:lang] ||= "de")
        estimate = options[:estimate] || false
        puts "#{Time.now}: import_all_products_from_csv: file_name #{file_name} lang #{lang} estimate #{estimate}"
        @csv_file = File.expand_path(file_name)
        @data_dir = File.dirname(@csv_file)
        FileUtils.mkdir_p @data_dir
        lang.upcase
        total = File.readlines(file_name).to_a.length
        count = 0
        @nr_products_before = get_nr_active_bauerfeind_products
        delete_all_inactive_bauerfeind_products
        Migel::Util::Server.new.all_products
        CSV.foreach(file_name, col_sep: ";") do |line|
          count += 1
          migel_code = line[5]
          next if /Migel/i.match?(migel_code)

          if line[4].nil? || line[4].empty?
            puts "#{Time.now}: Missing pharmacode in line #{count}: #{line}"
            next
          end
          @nr_records += 1
          ean13 = line[1]
          if (migelid = Migel::Model::Migelid.find_by_migel_code(migel_code))
            pharmacode = line[4]
            nr_invalids = migelid.products.count { |i| i.pharmacode.to_i.zero? }
            if nr_invalids.positive?
              puts "#{Time.now}: Deactivating non digital pharmacode #{pharmacode} for #{migel_code} found via #{line}"
              migelid.products.delete_if { |i| i.pharmacode.to_i.zero? }
              migelid.save
            end
            with_matching_ean = migelid.products.find_all { |i| i.ean_code == ean13 }
            with_matching_pharmacode = migelid.products.find_all do |i|
              i.pharmacode.to_i != 0 && i.pharmacode == pharmacode
            end
            record = {
              ean_code: ean13,
              pharmacode: pharmacode,
              ppub: line[6].gsub(/\s|Fr\./, ""),
              article_name_de: line[7].gsub(/,([^\s])/, ', \\1'),
              article_name_fr: line[8].gsub(/,([^\s])/, ', \\1')
            }
            # puts "#{Time.now}: Short/long do not match in line #{count}: #{line}" unless line[3].eql?(line[8]) && line[2].eql?(line[7])
            @migel_codes_with_products << migel_code
            if with_matching_pharmacode.size == 1
              update_product_from_csv(migelid, record)
              if estimate
                puts "#{Time.now}: updating via_pharmacode: " + estimate_time(@start_time, total, count,
                  " ") + "migel_code: #{migel_code}"
              end
            elsif with_matching_ean.size >= 1
              update_product_from_csv(migelid, record)
              if estimate
                puts "#{Time.now}: updating via_ean: " + estimate_time(@start_time, total, count,
                  " ") + "migel_code: #{migel_code} ean13 #{ean13}"
              end
            elsif with_matching_ean.empty? && with_matching_pharmacode.empty?
              update_product_from_csv(migelid, record)
              if estimate
                puts "#{Time.now}: Added as no matching ean/pharmacode found: " + estimate_time(@start_time, total,
                  count, " ") + "migel_code: #{migel_code} #{ean13}/#{pharmacode}"
              end
            elsif estimate
              puts "#{Time.now}: Skipping : " + estimate_time(@start_time, total, count,
                " ") + "migel_code: #{migel_code} #{ean13}/#{pharmacode}"
            end
          else
            @migel_codes_without_products << migel_code
            if estimate
              puts "#{Time.now}: ignoring as no code found: " + estimate_time(@start_time, total, count,
                " ") + "migel_code: #{migel_code} ean13 #{ean13}"
            end
          end
        end
        clear_inactive_bauerfeind_products
        @nr_products_after = get_nr_active_bauerfeind_products
        puts "#{Time.now}: finished: count #{count}: @nr_records #{@nr_records} " \
             "@migel_codes_without_products #{@migel_codes_without_products.size} @migel_codes_with_products #{@migel_codes_with_products.uniq}"
        restart_migel_server
        true
      end

      private

      def delete_all_inactive_bauerfeind_products
        total = 0
        Migel::Model::Migelid.all.each do |migel_id|
          nr_deleted = 0
          migel_code = migel_id.migel_code
          migel_id.products.find_all do |x|
            x&.companyname&.de && /bauerfeind/i.match(x.companyname.de.force_encoding("UTF-8"))
          end.each do |product|
            puts("#{Time.now}: delete_all_bauerfeind_products. #{product.odba_id} #{product.pharmacode} #{product.ean_code} #{migel_code}")
            product.odba_delete
            nr_deleted += 1
          end
          next if nr_deleted.zero?

          migel_id.products.delete_if do |x|
            x&.companyname&.de && /bauerfeind/i.match(x.companyname.de.force_encoding("UTF-8"))
          end
          puts("#{Time.now}: Deleted #{nr_deleted} products from #{migel_code}")
          migel_id.odba_store
          total += nr_deleted
        end
        Migel::Model::Product.all.odba_store unless defined?(RSpec)
        Migel::Model::Migelid.all.odba_store unless defined?(RSpec)
        # Now we need to check whether there are products laying around, which no valid migel_code, but still belong to Bauerfeind.
        nr_bauerfeind = Migel::Model::Product.all.count { |x| /bauerfeind/i.match(x.companyname.to_s) }
        puts("#{Time.now}: Deleted #{total} products. Having #{get_nr_active_bauerfeind_products} active_bauerfeind_products of #{nr_bauerfeind}")
        if nr_bauerfeind.positive?
          second = 0
          Migel::Model::Product.all.find_all { |x| /bauerfeind/i.match(x.companyname.to_s) }.each do |product|
            puts("#{Time.now}: delete_all_bauerfeind_products. #{product.odba_id} #{product.pharmacode} #{product.ean_code}")
            product.odba_delete
            second += 1
          end
          Migel::Model::Product.all.odba_store unless defined?(RSpec)
          Migel::Model::Migelid.all.odba_store unless defined?(RSpec)
          nr_bauerfeind = Migel::Model::Product.all.count { |x| /bauerfeind/i.match(x.companyname.to_s) }
          puts("#{Time.now}: Second deleted of  #{second} products. Having #{get_nr_active_bauerfeind_products} active_bauerfeind_products of #{nr_bauerfeind}")
        end
        get_nr_active_bauerfeind_products
        puts("#{Time.now}: Done with delete_all_bauerfeind_products (Deleted #{total} products. Having #{get_nr_active_bauerfeind_products} active_bauerfeind_products")
      end

      def restart_migel_server(sleep_time = defined?(RSpec) ? 0 : 5)
        pid = `/bin/ps  -C ruby -Opid | /bin/grep migeld | /usr/bin/awk '{print $1}'`
        if pid.to_i != 0
          puts("restarting migel server. Pid to kill is #{pid}")
          res = system("/bin/kill #{pid}")
          sleep(sleep_time)
          puts("#{Time.now}: restart_export_server. Done sleeping #{sleep_time} seconds. res was #{res}")
        else
          puts("#{Time.now}: no migeld found to kill")
        end
      end

      def get_nr_active_bauerfeind_products
        Migel::Model::Product.all.count { |x| x.status == "A" && /bauerfeind/i.match(x.companyname.to_s) }
      end

      def clear_inactive_bauerfeind_products
        items = 0
        Migel::Model::Migelid.all.each do |migel_id|
          migel_code = migel_id.migel_code
          nr_invalids = migel_id.products.count do |x|
            x.status == "I" && /Bauerfeind/i.match(x.companyname.to_s)
          end
          next unless nr_invalids.positive?

          items += nr_invalids
          puts "#{Time.now}: Total #{items}: Deleting  #{nr_invalids} items for #{migel_code} by Bauerfeind"
          migel_id.products.delete_if { |x| x.status == "I" && /Bauerfeind/i.match(x.companyname.to_s) }
          migel_id.save
        end
        puts "#{Time.now}: Deleted #{items} inactive Bauerfeind items"
      end

      def set_bauerfeind_products_inactive
        items = 0
        Migel::Model::Product.all.find_all do |x|
          x.status == "A" && /bauerfeind/i.match(x.companyname.to_s)
        end.each do |x|
          x.status = "I"
          x.save
          items += 1
        end
        puts "#{Time.now}: Set #{items} Bauerfeind items to inactive"
      end

      def update_product_from_csv(migelid, record)
        key_value = (record[:pharmacode].to_i != 0) ? record[:pharmacode] : record[:ean_code]
        product = migelid.products.find { |i| i.pharmacode.eql?(key_value) } || begin
          migelid.products.size
          Migel::Util::Server.new.all_products.size
          i = Migel::Model::Product.new(key_value)
          sleep 0.01
          migelid.products.push i
          sleep 0.01
          migelid.save
          i
        end
        product.migelid = migelid
        product.pharmacode = key_value unless product.pharmacode.eql?(key_value)
        product.ean_code = record[:ean_code]
        product.send(:companyname).send(:de=, Companyname_DE)
        product.send(:companyname).send(:fr=, Companyname_FR)
        product.status = STATUS_CSV_ITEMS
        product.ppub = record[:ppub]
        product.send(:article_name).send(:de=, record[:article_name_de])
        product.send(:article_name).send(:fr=, record[:article_name_fr])
        product.save
      end
    end
  end
  include Migel::Util
end
