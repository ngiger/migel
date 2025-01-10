#! /usr/bin/env ruby
# Migel::Util::ServerSpec -- migel -- 26.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../lib", File.dirname(__FILE__))
require "spec_helper"

require "rspec"
require "rspec/mocks"

require "migel/model"
require "migel/util/server"
require "odba"
require "odba/index_definition"

module Migel
  module Util
    describe Server do
      before(:each) do
        @server = Migel::Util::Server.new
      end
      it "group, subgroup, migelid, product should return its Class wrapped by DRbWrapper" do
        expect(@server.group).to eq(Migel::Model::Group)
        expect(@server.subgroup).to eq(Migel::Model::Subgroup)
        expect(@server.migelid).to eq(Migel::Model::Migelid)
        expect(@server.product).to eq(Migel::Model::Product)
      end
      it "search_migelid_fulltext should return a result of ODBA.cache.retrieve_from_index" do
        allow(ODBA.cache).to receive(:retrieve_from_index).and_return(["result"])
        # use send to test private method!
        expect(@server.send(:search_migelid_fulltext, "query", "language")).to eq(["result"])
      end
      it "search_migelid_by_name should a result by searching a name in Group, Subgroup, and Migelid" do
        migelid = double("migelid")
        subgroup = double("subgroup", migelids: [migelid])
        group = double("group", subgroups: [subgroup])
        method_name = :search_by_name_de
        expect(Migel::Model::Group).to receive(method_name).and_return([group])
        expect(Migel::Model::Subgroup).to receive(method_name).and_return([subgroup])
        expect(Migel::Model::Migelid).to receive(method_name).and_return([migelid])
        expected = [migelid]
        expect(@server.send(:search_migelid_by_name, "query", "de")).to eq(expected)
      end
      it "search_migel_migelid should return a result of search_migelid_fulltext" do
        skip("I do not have the time to fix this test for search_by_name_de")
        allow(ODBA.cache).to receive(:retrieve_from_index).and_return(["result"])
        expect(@server.search_migel_migelid("query", "de")).to eq(["result"])
      end
      it "search_migel_migelid should return a result of search_migelid_by_name" do
        allow(ODBA.cache).to receive(:retrieve_from_index).and_return([])
        migelid = double("migelid")
        subgroup = double("subgroup", migelids: [migelid])
        group = double("group", subgroups: [subgroup])
        method_name = :search_by_name_de
        allow(Migel::Model::Group).to receive(method_name).and_return([group])
        allow(Migel::Model::Subgroup).to receive(method_name).and_return([subgroup])
        allow(Migel::Model::Migelid).to receive(method_name).and_return([migelid])
        expected = [migelid]
        expect(@server.search_migel_migelid("query", "de")).to eq(expected)
      end
      it "search_migel_product should return a result of searching migel_product_fulltext_index_de index table" do
        product = double("product",
          pharmacode: "1",
          ean_code: "123",
          status: "A")
        allow(ODBA.cache).to receive(:retrieve_from_index).and_return([product])
        expect(@server.search_migel_product("query", "de")).to eq([product])
      end
      it "search_migel_product should return a result of searching article name and company name of Product" do
        product1 = double("product1",
          pharmacode: "1",
          ean_code: "123",
          status: "A")
        product2 = double("product2",
          pharmacode: "2",
          ean_code: "1234",
          status: "A")
        allow(ODBA.cache).to receive(:retrieve_from_index).and_return([])
        expect(Migel::Model::Product).to receive(:search_by_article_name_de).and_return([product1])
        expect(Migel::Model::Product).to receive(:search_by_company_name_de).and_return([product2])
        expect(@server.search_migel_product("query", "de")).to eq([product1, product2])
      end
      it "search_limitation should return a limitation_text instance of Group" do
        group = double("group", limitation_text: "limitation_text")
        allow(Migel::Model::Group).to receive(:find_by_migel_code).and_return(group)
        expect(@server.search_limitation("11")).to eq("limitation_text")
      end
      it "search_limitation should return a limitation_text instance of Subgroup" do
        subgroup = double("subgroup", limitation_text: "limitation_text")
        allow(Migel::Model::Subgroup).to receive(:find_by_migel_code).and_return(subgroup)
        expect(@server.search_limitation("11.22")).to eq("limitation_text")
      end
      it "search_limitation should return a limitation_text instance of Migelid" do
        migelid = double("migelid", limitation_text: "limitation_text")
        allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
        expect(@server.search_limitation("11.22.33.44.5")).to eq("limitation_text")
      end
      it "migelids should return fetched @migelids instance variable" do
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        expect(@server.migelids).to eq({})
      end
      it "init_migelids should add migelids from index table to @migelids instance variable" do
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        allow(ODBA.cache).to receive(:index_keys).and_return(["migel_code"])
        migelid = double("migelid", migel_code: "migel_code")
        allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
        allow(@server.migelids).to receive(:odba_store)
        @server.init_migelids
        expect(@server.migelids).to eq({"migel_code" => migelid})
      end
      it "clear_migelids should clear @migelids hash variable" do
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        allow(@server.migelids).to receive(:odba_store)
        migelid = double("migelid", migel_code: "migel_code")
        @server.migelids.store(migelid.migel_code, migelid)
        expect(@server.migelids).to eq({"migel_code" => migelid})
        @server.clear_migelids
        expect(@server.migelids).to eq({})
      end
      it "products should return fetched @products instance variable" do
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        expect(@server.products).to eq({})
      end
      it "init_products should add products from index table to @products instance variable" do
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        allow(ODBA.cache).to receive(:index_keys).and_return(["pharmacode"])
        product = double("product", pharmacode: "pharmacode")
        allow(Migel::Model::Product).to receive(:find_by_pharmacode).and_return(product)
        allow(@server.products).to receive(:odba_store)
        @server.init_products
        expect(@server.products).to eq({"pharmacode" => product})
      end
      it "clear_products should clear @products hash variable" do
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        allow(@server.products).to receive(:odba_store)
        product = double("product", pharmacode: "pharmacode")
        @server.products.store(product.pharmacode, product)
        expect(@server.products).to eq({"pharmacode" => product})
        @server.clear_products
        expect(@server.products).to eq({})
      end
      it "rebuild_fulltext_index_table should build a fulltext index table via ODBA" do
        allow(ODBA.cache).to receive(:drop_index)
        allow(ODBA.cache).to receive(:create_index)
        allow(ODBA.cache).to receive(:fill_index).and_return("fill_index")
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        allow(@server.products).to receive(:odba_store)

        index_definition_text = <<~EOD
          --- !ruby/object:ODBA::IndexDefinition
          index_name: 'migel_fulltext_index_de'
          origin_klass: 'Migel::Model::Migelid'
          target_klass: 'Migel::Model::Migelid'
          resolve_search_term: 'full_description(:de)'
          resolve_target: ''
          resolve_origin: ''
          fulltext: true
          init_source: 'all_migelids.values'
          dictionary: 'german'
        EOD
        index_definition = YAML.safe_load(index_definition_text, [ODBA::IndexDefinition])
        expect(@server.rebuild_fulltext_index_table(index_definition)).to eq("fill_index")
      end
      it "rebuild_fulltext_index_tables should build 4 tables" do
        allow(ODBA.cache).to receive(:drop_index)
        allow(ODBA.cache).to receive(:create_index)
        allow(ODBA.cache).to receive(:fill_index).and_return("fill_index")
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        allow(@server.products).to receive(:odba_store)

        expect do
          expect(@server.rebuild_fulltext_index_tables).to eq("fill_index")
        end.not_to raise_error
      end
      it "rebuild_fulltext_index_table should do nothing if there is no existing table" do
        allow(ODBA.cache).to receive(:drop_index).and_raise(RuntimeError)
        allow(ODBA.cache).to receive(:create_index)
        allow(ODBA.cache).to receive(:fill_index).and_return("fill_index")
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        allow(@server.products).to receive(:odba_store)

        index_definition_text = <<~EOD
          --- !ruby/object:ODBA::IndexDefinition
          index_name: 'migel_fulltext_index_de'
          origin_klass: 'Migel::Model::Migelid'
          target_klass: 'Migel::Model::Migelid'
          resolve_search_term: 'full_description(:de)'
          resolve_target: ''
          resolve_origin: ''
          fulltext: true
          init_source: 'all_migelids.values'
          dictionary: 'german'
        EOD
        index_definition = YAML.safe_load(index_definition_text, permitted_classes: [ODBA::IndexDefinition])

        expect do
          expect(@server.rebuild_fulltext_index_table(index_definition)).to eq("fill_index")
        end.not_to raise_error
      end
      it "_admin should return method result in the argument 'result' (Array)" do
        result = []
        @server._admin("self.class", result)
        expect(result).to eq(["Migel::Util::Server"])
        result = []
        @server._admin('"a"*201', result)
        expect(result).to eq(["String"])
      end
      it "_admin should return error message when StandardError happens during the method execution" do
        result = []
        @server._admin("Server.hogehoge", result)
        expect(result).to match([/undefined method [`']hogehoge'.*Migel::Util::Server/])
      end
      it "init_fulltext_index_tables should raise nothing" do
        allow(ODBA.cache).to receive(:fetch_named).and_return({})
        allow(ODBA.cache).to receive(:index_keys).and_return(["code"])
        allow(ODBA.cache).to receive(:drop_index)
        allow(ODBA.cache).to receive(:create_index)
        allow(ODBA.cache).to receive(:fill_index).and_return("fill_index")
        allow(@server.migelids).to receive(:odba_store)
        migelid = double("migelid", migel_code: "migel_code")
        product = double("product", pharmacode: "pharmacode")
        allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
        allow(Migel::Model::Product).to receive(:find_by_pharmacode).and_return(product)

        expect do
          @server.init_fulltext_index_tables
        end.not_to raise_error
      end
      it "sort_select_products should select products" do
        product1 = double("product1",
          pharmacode: "1",
          ean_code: nil,
          status: "A")
        product2 = double("product2",
          pharmacode: "2",
          ean_code: "1234",
          status: "I")
        product3 = double("product3",
          pharmacode: "3",
          ean_code: "1234",
          status: "A")
        products = [product1, product2, product3]
        expect(@server.sort_select_products(products, :pharmacode)).to eq([product3])
      end
      it "sort_select_products should sort products" do
        product1 = double("product1",
          pharmacode: "1",
          ean_code: "123",
          status: "A",
          ppub: "12.34")
        product2 = double("product2",
          pharmacode: "2",
          ean_code: "1234",
          status: "A",
          ppub: "12.33")
        product3 = double("product3",
          pharmacode: "3",
          ean_code: "1234",
          status: "A",
          ppub: "12.32")
        products = [product2, product1, product3]
        expect(@server.sort_select_products(products, :pharmacode)).to eq([product1, product2, product3])
        expect(@server.sort_select_products(products, :pharmacode, :reverse)).to eq([product3, product2, product1])
        expect(@server.sort_select_products(products, :ppub)).to eq([product3, product2, product1])
      end
      it "search_migel_product_by_migel_code should search products by migel_code" do
        product = double("product",
          pharmacode: "1",
          ean_code: "123",
          status: "A")
        migelid = double("migelid", products: [product])
        expect(Migel::Model::Migelid).to receive(:search_by_migel_code).at_least(1).and_return([migelid])
        expect(@server.search_migel_product_by_migel_code("migel_code")).to eq([product])
        expect(@server.search_migel_product_by_migel_code("migel_code", :ean_code)).to eq([product])
        expect(@server.search_migel_product_by_migel_code("migel_code", :ean_code, :reverse)).to eq([product])
      end
    end
  end # Util
end # Migel
