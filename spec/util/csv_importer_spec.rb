#! /usr/bin/env ruby

# Migel::Util::ImporterSpec -- migel -- 05.10.2011 -- mhatakeyama@ywesee.com
$: << File.expand_path("../../lib", File.dirname(__FILE__))
require "yaml"
require "rspec"
require "rspec/mocks"
require "spec_helper"
require "migel/model_super"
require "migel/model/group"
require "migel/util/csv_importer"
require "migel/model"
require "migel/util/mail"
require "migel/util/server"
require "odba"
require "mail"
include Migel::Util  # rubocop:disable  Style/MixinUsage

module Migel
  module Util
    def set_test_mail
      ::Mail.defaults do
        delivery_method :test
      end
      ::Mail::TestMailer.deliveries.clear
    end

    describe CsvImporter, "CSV file does not exist" do
      before(:each) do
        set_test_mail
        @importer = Migel::Util::CsvImporter.new
        expect(Migel::Model::Product).to receive(:all).with(no_args).and_return([]).at_least(1)
      end
      it "import_all_products_from_csv must return false" do
        file_to_import = File.expand_path(File.join(File.dirname(__FILE__), "..", "data", "should_not_exist.csv"))
        expect(@importer.import_all_products_from_csv({filename: file_to_import})).to eq(false)
        report = @importer.report
        expect(report.find { |line| /Total time to update/.match(line) }).not_to eq(nil)
        no_imports = "Total     0 Migelids (    0 Migelids have products /     0 Migelids have no products)"
        expect(report.find { |line| no_imports.eql?(line) }).to eq(no_imports)
        no_csv_file = "Read CSV-file: "
        expect(report.find { |line| no_csv_file.eql?(line) }).to eq(no_csv_file)
      end
    end

    describe CsvImporter, "Default options (with non existing file) passed" do
      before(:each) do
        set_test_mail
        @importer = Migel::Util::CsvImporter.new
        expect(Migel::Model::Product).to receive(:all).with(no_args).and_return([]).at_least(1)
      end
      it "import_all_products_from_csv must return false" do
        options = {
          report: true,
          estimate: true,
          filename: "/var/www/migel/data/csv/update_migel_bauerfeind.csv2"
        }
        expect(@importer.import_all_products_from_csv(options)).to eq(false)
        report = @importer.report
        expect(report.find { |line| /Total time to update/.match(line) }).not_to eq(nil)
        no_imports = "Total     0 Migelids (    0 Migelids have products /     0 Migelids have no products)"
        expect(report.find { |line| no_imports.eql?(line) }).to eq(no_imports)
        no_csv_file = "Read CSV-file: "
        expect(report.find { |line| no_csv_file.eql?(line) }).to eq(no_csv_file)
      end
    end
    MIGELTESTCODE = "05.02.03.00.1"
    VENOTRAINCODE = "17.01.02.00.1"
    GENUTRAINCODE = "05.04.04.00.1"
    describe CsvImporter, "Examples" do
      before(:each) do
        set_test_mail
        allow(ODBA.cache).to receive(:index_keys).and_return(["migel_code"])
        double("multilingual")
        multilingual_company = double("multilingual_company")
        expect(multilingual_company).to receive(:de).with(no_args).and_return("Bauerfeind AG").at_least(1)
        # expect(multilingual_company).to receive(:de=).with('Bauerfeind AG').and_return(nil)
        # expect(multilingual_company).to receive(:fr=).with('Bauerfeind SA').and_return(nil)

        multilingual = double("multilingual")
        # expect(multilingual).to receive(:de=).with('AchilloTrain, titan, rechts, 1').and_return(nil)
        # expect(multilingual).to receive(:fr=).with('AchilloTrain, titane, droit, 1').and_return(nil)
        expect(multilingual).to receive(:save).with(no_args).and_return(nil).never
        product_2244350 = double("product_2244350",
          :article_name => multilingual,
          :migel_code => MIGELTESTCODE,
          :ean_code= => nil,
          :pharmacode => "2244350",
          :odba_delete => nil)
        venotrain_names = double("venotrain_names")
        expect(venotrain_names).to receive(:de=).with(any_args).and_return(nil).never
        expect(venotrain_names).to receive(:fr=).with(any_args).and_return(nil).never
        expect(venotrain_names).to receive(:save).with(no_args).and_return(nil).never

        product_with_ean = double("product_with_ean",
          :article_name => multilingual,
          :migel_code => VENOTRAINCODE,
          :ean_code => "4026358067614",
          :ean_code= => nil)
        expect(product_with_ean).to receive(:pharmacode).with(no_args).and_return(nil).never
        migelid = double("migelid",
          migel_code: MIGELTESTCODE,
          delete: true,
          products: [product_2244350],
          add_product: nil,
          odba_store: nil,
          save: nil)
        expect(product_2244350).to receive(:migelid=).and_return(nil).never
        expect(product_2244350).to receive(:migelid).and_return(migelid).never
        expect(product_2244350).to receive(:ppub=).with("120.50").and_return(nil).never
        expect(product_2244350).to receive(:save).with(no_args).and_return(nil).never
        expect(product_2244350).to receive(:ean_code).with(no_args).and_return("4046445108532")
        expect(product_2244350).to receive(:ean_code=).with("4046445108009").and_return(nil).never
        expect(product_2244350).to receive(:ean_code=).with("4046445108532").and_return(nil).never
        @status_2244350 = nil
        expect(product_2244350).to receive(:status=).with("A").and_return(@status_2244350 = "A").never
        expect(product_2244350).to receive(:status).and_return("A").at_least(1)
        expect(product_2244350).to receive(:companyname).with(no_args).and_return(multilingual_company).at_least(1)
        @status_with_ean = nil
        expect(product_with_ean).to receive(:companyname).with(no_args).and_return(multilingual_company).at_least(1)
        expect(product_with_ean).to receive(:status).and_return("A")
        expect(product_with_ean).to receive(:status).and_return(@status_with_ean).at_least(1)
        @server = Migel::Util::Server.new
        allow_any_instance_of(DRbObject).to receive(:session).and_return(@server)
        allow(DRbObject).to receive(:new).and_return(@server)
        allow(ODBA.cache).to receive(:fetch_named).with("all_products", any_args).and_return({MIGELTESTCODE => product_2244350, VENOTRAINCODE => product_with_ean})
        expect(Migel::Model::Product).to receive(:all).with(no_args).and_return([product_2244350, product_with_ean]).at_least(1)
        expect(Migel::Model::Migelid).to receive(:all).with(no_args).and_return([migelid]).once
        expect(Migel::Model::Migelid).to receive(:all).with(no_args).and_return([]).once
        expect(Migel::Model::Migelid).to receive(:find_by_migel_code).with("9999.99.99.99").and_return(nil).once
        migelid_genutrain = double("migelid_genutrain",
          migel_code: GENUTRAINCODE,
          delete: true,
          products: [],
          add_product: nil,
          save: nil)
        expect(Migel::Model::Migelid).to receive(:find_by_migel_code).with(GENUTRAINCODE).and_return(migelid_genutrain).at_least(1)
        expect(Migel::Model::Migelid).to receive(:find_by_migel_code).with(MIGELTESTCODE).and_return(migelid).twice
        expect(Migel::Model::Migelid).to receive(:find_by_migel_code).with(VENOTRAINCODE).and_return(migelid).once
        double("group",
          name: "name",
          update_limitation_text: nil,
          save: nil)
        allow(Migel::Model::Group).to receive(:find_by_code)
        @importer = Migel::Util::CsvImporter.new
      end
      it "import_all_products_from_csv" do
        file_to_import = File.expand_path(File.join(File.dirname(__FILE__), "..", "data", "update_migel_bauerfeind.csv"))
        expect(@importer.import_all_products_from_csv({filename: file_to_import})).to eq(true)
        report = @importer.report
        expect(report.find { |line| /Total time to update/.match(line) }).not_to eq(nil)
        success = "Total     6 Migelids (    5 Migelids have products /     1 Migelids have no products)"
        expect(report.find { |line| success.eql?(line) }).to eq(success)
        expect(report.count { |line| /found via Bauerfeind AG or Bauerfeind SA were. Active products before/.match(line) }).to eq 1
        expected = "Migelids with products (5)"
        expect(report.find { |line| expected.eql?(line) }).to eq(expected)
        expect(::Mail::TestMailer.deliveries.size).to eq(1)
        expect(::Mail::TestMailer.deliveries.first.to_s).not_to match(/RuntimeError/)
        expect(::Mail::TestMailer.deliveries.first.to_s.index(expected)).not_to eq nil
      end
    end
  end # Util
end # Migel
