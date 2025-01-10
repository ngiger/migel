#!/usr/bin/env ruby
# frozen_string_literal: true

# Migel::Importer -- migel -- 13.02.2012 -- yasaka@ywesee.com
# Migel::Importer -- migel -- 06.01.2012 -- mhatakeyama@ywesee.com

require "csv"
require "fileutils"
require "zlib"
require "migel/util/mail"
require "migel/plugin/swissindex"
require "spreadsheet"
require "open-uri"
require "migel/util/server"

module Migel
  LANGUAGE_NAMES = {"de" => "MiGeL",
                    "fr" => "LiMA",
                    "it" => "EMAp"}.freeze

  module Util
    def estimate_time(start_time, total, count, lb = "\n")
      estimate = (Time.now - start_time) * total / count
      log = "#{format("%3d", count.to_s)} / #{total}\t"
      em = estimate / 60
      eh = em / 60
      rest = estimate - (Time.now - start_time)
      rm = rest / 60
      rh = rm / 60
      log << "Estimate total: "
      log << if eh > 1.0
        "#{"%.2f" % eh} [h]"
      else
        "#{"%.2f" % em} [m]"
      end
      log << " It will be done in: "
      log << if rh > 1.0
        "#{"%.2f" % rh} [h]"
      else
        "#{"%.2f" % rm} [m]"
      end
      log << lb
      log
    end

    class Importer
      attr_reader :data_dir, :xls_file

      ORIGINALXLS = "https://github.com/zdavatz/oddb2xml_files/raw/master/MiGeL.xls"
      SALE_TYPES = {
        "1" => :purchase,
        "2" => :rent,
        "3" => :both
      }.freeze
      Produktegruppe_Nr = 0 # rubocop:disable Naming/ConstantName
      Limitation_Produktegruppe = 1 # rubocop:disable Naming/ConstantName
      Produktegruppe = 2 # rubocop:disable Naming/ConstantName
      Beschreibung_Produktegruppe = 3 # rubocop:disable Naming/ConstantName
      Kategorie_Nr = 4 #  Kategorie Nr  # rubocop:disable Naming/ConstantName
      Kategorie = 6 # rubocop:disable Naming/ConstantName
      Beschreibung_Kategorie = 7 # rubocop:disable Naming/ConstantName
      Unterkategorie = 12 # rubocop:disable Naming/ConstantName
      Positions_Nummer = 15 # rubocop:disable Naming/ConstantName
      Limitation = 16 # rubocop:disable Naming/ConstantName
      Bezeichnung = 17 # rubocop:disable Naming/ConstantName
      Menge = 18 # rubocop:disable Naming/ConstantName
      Einheit = 19 # rubocop:disable Naming/ConstantName
      Max_Price = 20 #      Höchstvergütungsbetrag = # rubocop:disable Naming/ConstantName
      Revision_Valid_since = 22 # Revision Gültig ab # rubocop:disable Naming/ConstantName

      def initialize
        @data_dir = File.expand_path("../../../data/csv", File.dirname(__FILE__))
        $stdout.sync = true
        FileUtils.mkdir_p @data_dir
        @xls_file = File.join(@data_dir, File.basename(ORIGINALXLS))
        @start_time = Time.now
      end

      def date_object(date)
        date = date.to_s.split(".")
        return unless date.size == 3

        Date.new(date.at(2).to_i, date.at(1).to_i, date.at(0).to_i)
      end

      def check_headers(row)
        expected = {
          Produktegruppe_Nr => "Produktegruppe Nr",
          Produktegruppe => "Produktegruppe",
          Beschreibung_Produktegruppe => "Beschreibung Produktegruppe",
          Kategorie_Nr => "Kategorie Nr",
          Kategorie => "Kategorie",
          Beschreibung_Kategorie => "Beschreibung Kategorie",
          Unterkategorie => "Unterkategorie",
          Positions_Nummer => "Positions Nummer",
          Limitation => "Limitation",
          Bezeichnung => "Bezeichnung",
          Menge => "Menge",
          Einheit => "Einheit",
          Max_Price => "Höchstvergütungsbetrag",
          Revision_Valid_since => "Revision Gültig ab"
        }
        expected.each do |key, value|
          next if row[key].eql?(value)

          raise "Unexpected name #{row[key]} for key #{key} #{value}"
        end
      end

      def update_all
        puts "#{Time.now}: update_all using #{@xls_file}"
        base = File.basename(@xls_file, ".xls")
        xls = File.open(@xls_file, "wb+")
        File.open(ORIGINALXLS) { |f| xls.write(f.read) }
        xls.close
        act_content = File.read(@xls_file)

        latest = File.join(@data_dir, "#{base}-latest.xls")
        target = File.join(@data_dir, "#{base}-#{Time.now.strftime("%Y.%m.%d")}.xls")
        if !File.exist?(target) || File.read(target) != act_content
          FileUtils.cp(@xls_file, target, verbose: true, preserve: true)
        end
        return if File.exist?(latest) && File.read(latest) == act_content

        puts "#{Time.now}: update_all #{@xls_file} taken from #{ORIGINALXLS}"
        book = Spreadsheet.open @xls_file
        LANGUAGE_NAMES.each do |language, name|
          sheet = book.worksheet(name)
          check_headers(sheet.rows.first) if language.eql?("de")
          csv_name = File.join(@data_dir, "migel_#{language}.csv")
          idx = 0
          CSV.open(csv_name, "w", force_quotes: true) do |writer|
            sheet.rows.each do |row|
              next unless row.first

              # fix conversion to date
              if idx.positive?
                begin
                  if (date = Date.parse(row[Revision_Valid_since].to_s, "%Y.%m%.%d"))
                    row[Revision_Valid_since] = date.strftime("%d.%m.%Y")
                  end
                rescue => e
                  puts "Error in file #{csv_name} in line #{idx}: #{e}"
                end
              end
              writer << row
              idx += 1
              if (idx % 500).zero?
                puts "#{Time.now}: update_all #{language} #{@xls_file} at row #{idx} #{row.at(POSITIONS_NUMMER)}"
              end
            end
          end
          update(csv_name, language)
        end
        FileUtils.mv(@xls_file, latest, verbose: true)
      end

      # for import groups, subgroups, migelids
      def update(path, language)
        puts "#{Time.now}: update #{path} #{language}"
        # update Group, Subgroup, Migelid data from a csv file
        CSV.readlines(path)[1..].each do |row|
          id = row.at(Positions_Nummer).to_s.split(".")
          if id.empty?
            id = row.at(Kategorie_Nr).to_s.split(".")
          else
            id[-1].replace(id[-1][0, 1])
          end
          next if id.empty?

          group = update_group(id, row, language)
          subgroup = update_subgroup(id, group, row, language)
          migel_code_list.delete(group.migel_code)
          migel_code_list.delete(subgroup.migel_code)
          next unless id.size > 2

          migelid = update_migelid(id, subgroup, row, language)
          migel_code_list.delete(migelid.migel_code)
          if migelid.date && migelid.date.year < 1900
            warn "#{__LINE__}: save migelid #{migelid.migel_code} #{migelid.date}"
          end
        end

        # delete not updated list
        migel_code_list.each do |migel_code|
          case migel_code.length
          when 2
            Migel::Model::Group.find_by_migel_code(migel_code)&.delete
          when 5
            Migel::Model::Subgroup.find_by_migel_code(migel_code)&.delete
          else
            Migel::Model::Migelid.find_by_migel_code(migel_code)&.delete
          end
        end
      end

      def update_group(id, row, language)
        groupcd = id.at(Produktegruppe_Nr)
        begin
          puts "#{Time.now}: update_group #{id} groupcd #{groupcd} #{language}" if id.size < 5
          group = Migel::Model::Group.find_by_code(groupcd) || Migel::Model::Group.new(groupcd)
          unless group
            puts "#{Time.now}: UNABLE to update_group #{id} groupcd #{groupcd} #{language}"
            return
          end
          group.name.send(:"#{language}=", row.at(Produktegruppe).to_s)
          text = row.at(Beschreibung_Produktegruppe).to_s
          text.tr!("\v", " ")
          text.dup.strip!
          group.update_limitation_text(text, language) unless text.empty?
          group.save
          group
        rescue
          0
        end
      end

      def update_subgroup(id, group, row, language)
        subgroupcd = id.at(Limitation_Produktegruppe)
        subgroup = group.subgroups.find { |sg| sg.code == subgroupcd } || begin
          sg = Migel::Model::Subgroup.new(subgroupcd)
          group.subgroups.push sg
          group.save
          sg
        end
        subgroup.group = group
        subgroup.name.send(:"#{language}=", row.at(Kategorie).to_s)
        if ((text = row.at(Beschreibung_Kategorie).to_s)) && !text.empty?
          subgroup.update_limitation_text(text, language)
        end
        subgroup.save
        subgroup
      end

      def update_migelid(id, subgroup, row, language)
        # take data from csv
        migelidcd = id[2, 3].join(".")
        name = row.at(Unterkategorie).to_s
        migelid_text = row.at(Bezeichnung).gsub(/[ \t]+/u, " ")
        migelid_text.tr!("\v", "\n")
        limitation_text = if (idx = migelid_text.index(/Limitation|Limitazione/u))
          migelid_text.slice!(idx..-1).strip
        else
          ""
        end
        name = migelid_text.slice!(/^[^\n]+/u) if name.to_s.strip.empty?
        migelid_text.strip!
        type = SALE_TYPES[id.at(4)]
        price = (row.at(Max_Price).to_s[/\d[\d.]*/u].to_f * 100).round
        begin
          date = row.at(Revision_Valid_since) ? Date.parse(row.at(Revision_Valid_since)) : nil
        rescue => e
          puts e
          0
        end
        row.at(Limitation)
        qty = row.at(Menge).to_i
        unit = row.at(Einheit).to_s
        # save instance
        begin
          migelid = subgroup.migelids.find { |mi| mi.respond_to?(:code) && mi.code == migelidcd } || begin
            mi = Migel::Model::Migelid.new(migelidcd)
            subgroup.migelids.push mi
            subgroup.save
            mi
          end
        rescue => e
          0
        end
        migelid.subgroup = subgroup
        migelid.save
        migelid.limitation_text(true)
        multilingual_data = {
          name: name,
          migelid_text: migelid_text,
          limitation_text: limitation_text,
          unit: unit
        }
        migelid.update_multilingual(multilingual_data, language)
        migelid.type = type
        migelid.price = price
        migelid.date = date
        if migelid.date && migelid.date.year < 1900
          warn "#{__LINE__}: Problem with #{migelid.migel_code} #{migelid.date}"
        end
        migelid.limitation = Limitation
        migelid.qty = qty if qty.positive?

        if id[3] != "00"
          1.upto(3) do |num|
            micd = [id[2], "00", num].join(".")
            if (mi = subgroup.migelids.find { |m| m.respond_to?(:code) && m.code == micd })
              migelid.add_migelid(mi)
            end
          rescue => e
            #              require 'pry'; binding.pry
            puts "migel #{id} #{group} #{e}"
            0
          end
        end

        migelid.save
        migelid
      end

      def save_all_products_all_languages(options = {report: false, estimate: false})
        LANGUAGE_NAMES.each_key do |language|
          file_name = File.join(@data_dir, "migel_products_#{language}.csv")
          reported_save_all_products(file_name, language, options[:estimate])
          if !defined?(RSpec) && !(File.exist?(file_name) && File.size(file_name) > 1024)
            raise "Trying to save emtpy (or too small) #{file_name}"
          end
        end
      end

      # for import products
      def reported_save_all_products(file_name = "migel_products_de.csv", lang = "de", estimate = false)
        @csv_file = File.join(@data_dir, File.basename(file_name))
        lines = [
          format("%s: %s %s#reported_save_all_products(#{lang})", Time.now.strftime("%c"), Migel.config.server_name,
            self.class)
        ]
        save_all_products(@csv_file, lang, estimate)
        compressed_file = compress(@csv_file)
        historicize(compressed_file)
        lines.concat report(lang)
      rescue => e
        lines.push(e.class.to_s, e.message, *e.backtrace)
        lines.concat report
      ensure
        subject = lines[0]
        Migel::Util::Mail.notify_admins_attached(subject, lines, compressed_file)
      end

      def historicize(filepath)
        archive_path = File.expand_path("../../../data", File.dirname(__FILE__))
        save_dir = File.join archive_path, "csv"
        FileUtils.mkdir_p save_dir
        archive = Date.today.strftime(filepath.gsub(".csv.gz", "-%Y.%m.%d.csv.gz"))
        puts "#{Time.now}: historicize #{filepath} -> #{archive}. Size is #{File.size(filepath)}"
        FileUtils.cp(filepath, archive)
      end

      def compress(file)
        puts "#{Time.now}: compress #{file}"
        compressed_filename = "#{file}.gz"
        Zlib::GzipWriter.open(compressed_filename, Zlib::BEST_COMPRESSION) do |gz|
          gz.mtime = File.mtime(file)
          gz.orig_name = file
          gz.puts File.binread(file)
        end
        compressed_filename
      end

      def report(lang = "de")
        lang = lang.downcase
        end_time = Time.now - @start_time
        @update_time = (end_time / 60.0).to_i
        res = [
          "Total time to update: #{format("%.2f", @update_time)} [m]",
          "Saved file: #{@csv_file}",
          format("Total %5i Migelids (%5i Migelids have products / %5i Migelids have no products)",
            migel_code_list ? migel_code_list.length : 0,
            @migel_codes_with_products ? @migel_codes_with_products.length : 0,
            @migel_codes_without_products ? @migel_codes_without_products.length : 0),
          "Saved #{@saved_products} Products"
        ]
        res += [
          "",
          "Migelids with products (#{@migel_codes_with_products ? @migel_codes_with_products.length : 0})"
        ]
        if @migel_codes_with_products
          res += @migel_codes_with_products.sort.map do |migel_code|
            "http://ch.oddb.org/#{lang}/gcc/migel_search/migel_product/#{migel_code}"
          end
        end
        res += [
          "",
          "Migelids without products (#{@migel_codes_without_products ? @migel_codes_without_products.length : 0})"
        ]
        if @migel_codes_without_products&.size&.positive?
          res[-1] += @migel_codes_without_products.sort.map do |migel_code|
            "http://ch.oddb.org/#{lang}/gcc/migel_search/migel_product/#{migel_code}"
          end.to_s
        end
        res
      end

      def code_list(index_table_name, output_filename = nil)
        list = ODBA.cache.index_keys(index_table_name)
        if output_filename
          File.open(output_filename, "w") do |out|
            out.print list.join("\n"), "\n"
          end
        end
        list
      end

      def migel_code_list(output_filename = nil)
        @migel_code_list ||= begin
          index_table_name = "migel_model_migelid_migel_code"
          code_list(index_table_name, output_filename)
        end
        @migel_code_list ||= []
      end

      def pharmacode_list(output_filename = nil)
        @pharmacode_list ||= begin
          index_table_name = "migel_model_product_pharmacode"
          code_list(index_table_name, output_filename)
        end
        @pharmacode_list ||= []
      end

      def unimported_migel_code_list(output_filename = nil)
        migel_codes = migel_code_list.select do |migel_code|
          migelid = Migel::Model::Migelid.find_by_migel_code(migel_code) and migelid.products.empty?
        end
        if output_filename
          File.open(output_filename, "w") do |out|
            out.print migel_codes.join("\n"), "\n"
          end
        end
        migel_codes
      end

      def missing_article_name_migel_code_list(lang = "de", output_filename = nil)
        migel_codes = migel_code_list.select do |migel_code|
          migelid = Migel::Model::Migelid.find_by_migel_code(migel_code) and !migelid.products.empty? and migelid.products.first.article_name.send(lang).to_s.empty?
        end
        if output_filename
          File.open(output_filename, "w") do |out|
            out.print migel_codes.join("\n"), "\n"
          end
        end
        migel_codes
      end

      def reimport_missing_data(lang = "de", estimate = false)
        migel_codes = missing_article_name_migel_code_list

        total = migel_codes.length
        start_time = Time.now
        migel_codes.each_with_index do |migel_code, count|
          update_products_by_migel_code(migel_code, lang)
          puts estimate_time(start_time, total, count + 1) if estimate
        end
        "#{migel_codes.length} migelids is updated."
      end

      def save_all_products(file_name = "migel_products_de.csv", lang = "de", estimate = false)
        plugin = Migel::SwissindexMigelPlugin.new(migel_code_list)
        @saved_products, @migel_codes_with_products, @migel_codes_without_products =
          plugin.save_all_products(file_name, lang, estimate)
      end

      def import_all_products_from_csv(file_name = "migel_products_de.csv", lang = "de", estimate = false)
        lang = lang.upcase
        start_time = Time.new
        total = File.readlines(file_name).to_a.length
        count = 0
        # update cache
        CSV.foreach(file_name) do |line|
          count += 1
          line[0] = line[0].rjust(9, "0") if /^\d{8}$/.match?(line[0])
          migel_code = if /^\d{9}$/.match?(line[0])
            line[0].split(/(\d\d)/).reject(&:empty?).join(".")
          elsif /^(\d\d)\.(\d\d)\.(\d\d)\.(\d\d)\.(\d)$/.match?(line[0])
            line[0]
          else
            "" # skip
          end
          if (migelid = Migel::Model::Migelid.find_by_migel_code(migel_code))
            record = {
              pharmacode: line[1],
              ean_code: line[2],
              article_name: line[3],
              companyname: line[4],
              companyean: line[5],
              ppha: line[6],
              ppub: line[7],
              factor: line[8],
              pzr: line[9],
              size: line[10],
              status: line[11],
              datetime: line[12],
              stdate: line[13],
              language: line[14]
            }
            update_product(migelid, record, lang)
            pharmacode_list.delete(line[1])
            puts "updating: #{estimate_time(start_time, total, count, " ")}migel_code: #{migel_code}" if estimate
          elsif estimate
            puts "ignoring: #{estimate_time(start_time, total, count, " ")}migel_code: #{migel_code}"
          end
        end

        # update database
        count = 0
        start_time = Time.new
        total = migel_code_list.length
        codes = migel_code_list.dup
        codes.each do |migel_code|
          count += 1
          if (migelid = Migel::Model::Migelid.find_by_migel_code(migel_code))
            migelid = migelid.dup
            migelid.products.each(&:save)
            warn "#{__LINE__}: saving migelid #{migelid.migel_code} #{migelid.date}"
            migelid.save
            puts "saving: #{estimate_time(start_time, total, count, " ")}migel_code: #{migel_code}" if estimate
          elsif estimate
            puts "ignoring: #{estimate_time(start_time, total, count, " ")}migel_code: #{migel_code}"
          end
        end

        # delete process
        pharmacode_list.each do |pharmacode|
          Migel::Model::Product.find_by_pharmacode(pharmacode).delete
        end
      end

      def update_products_by_migel_code(migel_code, lang = "de")
        lang = lang.upcase
        if (migelid = Migel::Model::Migelid.find_by_migel_code(migel_code))
          migel_code = migelid.migel_code.split(".").to_s
          if (table = ODDB::Swissindex.search_migel_table(migel_code, lang))
            table.each do |record|
              update_product(migelid, record, lang) if record[:pharmacode] && record[:article_name]
            end
          end
          migelid.products.each(&:save)
          warn "#{__LINE__}: saving migelid #{migelid.migel_code} #{migelid.date}"
          migelid.save
        end
      end

      private

      def update_product(migelid, record, lang = "de")
        lang.downcase!
        product = migelid.products.find { |i| i.pharmacode == record[:pharmacode] } || begin
          i = Migel::Model::Product.new(record[:pharmacode])
          sleep 0.01
          migelid.products.push i
          sleep 0.01
          #      migelid.save
          i
        end
        product.migelid = migelid
        # product.save

        product.ean_code = record[:ean_code]
        # product.article_name = record[:article_name]
        product.send(:article_name).send(:"#{lang}=", record[:article_name])
        # product.companyname  = record[:companyname]
        product.send(:companyname).send(:"#{lang}=", record[:companyname])
        product.companyean = record[:companyean]
        product.ppha = record[:ppha]
        product.ppub = record[:ppub]
        product.factor = record[:factor]
        product.pzr = record[:pzr]
        # product.size         = record[:size]
        product.send(:size).send(:"#{lang}=", record[:size])
        product.status = record[:status]
        product.datetime = record[:datetime]
        product.stdate = record[:stdate]
        product.language = record[:language]

        #    product.save
        product
      end
    end
  end
  include Migel::Util
end
