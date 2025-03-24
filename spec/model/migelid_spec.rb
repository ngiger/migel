#! /usr/bin/env ruby
# Migel::Model::MigelidSpec -- migel -- 05.10.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../lib", File.dirname(__FILE__))

require "rspec"
require "spec_helper"
require "migel/model_super"
require "migel/model/group"
require "migel/model/subgroup"
require "migel/model/migelid"
require "migel/util/multilingual"
require "odba/drbwrapper"

module Migel
  module Model
    group_code = "11"
    subgroup_code = "22"
    migelid_code = "33.44.5"
    describe Migelid, "when initialized with code #{migelid_code} (group_code: #{group_code}, subgroup_code: #{subgroup_code})" do
      before do
        @group = Group.new(group_code)
        @subgroup = Subgroup.new(subgroup_code)
        @migelid = Migelid.new(migelid_code)
        @group.subgroups << @subgroup
        @subgroup.group = @group
        @subgroup.migelids << @migelid
        @migelid.subgroup = @subgroup

        @group.name.de = "group"
        @subgroup.name.de = "subgroup"
        @migelid.name.de = "migelid"
        @migelid.migelid_text.de = "migelid_text"

        @migelid.add_accessory("accessory")
        @migelid.add_migelid(Migelid.new("777"))
      end
      it "code should be #{migelid_code}" do
        expect(@migelid.code).to eq(migelid_code)
      end
      it "migel_code should be #{group_code}.#{subgroup_code}.#{migelid_code}" do
        expect(@migelid.migel_code).to eq("#{group_code}.#{subgroup_code}.#{migelid_code}")
      end
      it "products should be empty" do
        expect(@migelid.products).to be_empty
      end
      it "accessories[0] should be 'accessory'" do
        expect(@migelid.accessories.first).to eq("accessory")
      end
      it "migelids[0].accessory[0] should be migelid" do
        expect(@migelid.migelids[0].accessories[0]).to eq(@migelid)
      end
      it "parent should be a subgroup" do
        expect(@migelid.parent).to eq(@subgroup)
        expect(@migelid.parent).to eq(@migelid.subgroup)
      end
      it "limitation_text.to_s should be ''" do
        expect(@migelid.limitation_text).to be_nil
        expect(@migelid.limitation_text.to_s).to eq("")
      end
      it "name.to_s should be 'migelid'" do
        expect(@migelid.name).to be_an_instance_of(Migel::Util::Multilingual)
        expect(@migelid.name.to_s).to eq("migelid")
      end
      it "name.de, en should be 'migelid'" do
        expect(@migelid.name.de).to eq("migelid")
        expect(@migelid.name.en).to eq("migelid")
      end
      it "name.fr should be nil" do
        expect(@migelid.name.fr).to be_nil
      end
      it "full_description should be 'group subgroup migelid migelid_text'" do
        expect(@migelid.full_description).to eq("group subgroup migelid migelid_text")
      end
      it "products.values should be products" do
        expect(@migelid.products.values).to eq(@migelid.products)
        expect(@migelid.products).to be_empty
      end
      it "pointer should be 'pointer'" do
        expect(@migelid.pointer).to eq("pointer")
      end
      it "localized_name should be migelid" do
        expect(@migelid.localized_name("de")).to eq("migelid")
      end
      it "structural_ancestors should be [group, subgroup]" do
        expect(@migelid.structural_ancestors("app")).to eq([@group, @subgroup])
      end
    end

    limitation_text = "limitation text"
    language = "de"
    describe Migelid, "when limitation_text is updated" do
      before do
        @group = Group.new(group_code)
        @subgroup = Subgroup.new(subgroup_code)
        @migelid = Migelid.new(migelid_code)
        @group.subgroups << @subgroup
        @subgroup.group = @group
        @subgroup.migelids << @migelid
        @migelid.subgroup = @subgroup
        data = {limitation_text: limitation_text}
        @migelid.update_limitation_text(limitation_text, language)
        @migelid.update_multilingual(data, language)
      end
      it "limitation_text.de should be '#{limitation_text}'" do
        expect(@migelid.limitation_text).to be_an_instance_of(Migel::Util::Multilingual)
        expect(@migelid.limitation_text.de).to eq("limitation text")
        expect(@migelid.limitation_text.to_s).to eq("limitation text")
        expect(@migelid.limitation_text.en).to eq("limitation text")
      end
      it "limitation_text.fr should be nil" do
        expect(@migelid.limitation_text.fr).to be_nil
      end
      it "limitation_text.parent should be migelid" do
        expect(@migelid.limitation_text.parent).to eq(@migelid)
      end
    end

    describe Migelid, "when name is updated" do
      before do
        @group = Group.new(group_code)
        @subgroup = Subgroup.new(subgroup_code)
        @migelid = Migelid.new(migelid_code)
        @group.subgroups << @subgroup
        @subgroup.group = @group
        @subgroup.migelids << @migelid
        @migelid.subgroup = @subgroup

        @migelid.name.de = "name.de"
        @migelid.name.fr = "name.fr"
      end
      it "name.de should be 'name.de'" do
        expect(@migelid.name.de).to eq("name.de")
        expect(@migelid.name.en).to eq("name.de")
        expect(@migelid.name.fr).to eq("name.fr")
        expect(@migelid.de).to eq("name.de")
        expect(@migelid.en).to eq("name.de")
        expect(@migelid.fr).to eq("name.fr")
      end
    end
  end # Model
end # Migel
