#! /usr/bin/env ruby
# Migel::Model::SubgroupSpec -- migel -- 09.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../lib", File.dirname(__FILE__))

require "rspec"
require "spec_helper"
require "migel/model_super"
require "migel/model/group"
require "migel/model/subgroup"
require "migel/util/multilingual"
require "odba/drbwrapper"

module Migel
  module Model
    group_code = 11
    subgroup_code = 22
    describe Subgroup, "when initialized with code #{subgroup_code} (group_code: #{group_code})" do
      before do
        @group = Group.new(group_code)
        @subgroup = Subgroup.new(subgroup_code)
        @group.subgroups << @subgroup
        @subgroup.group = @group
      end
      it "code should be #{subgroup_code}" do
        expect(@subgroup.code).to eq(subgroup_code)
      end
      it "migel_code should be #{group_code}.#{subgroup_code}" do
        expect(@subgroup.migel_code).to eq("#{group_code}.#{subgroup_code}")
      end
      it "migelids should be empty" do
        expect(@subgroup.migelids).to be_empty
      end
      it "parent should be group" do
        expect(@subgroup.parent).to eq(@group)
        expect(@subgroup.parent).to eq(@subgroup.group)
      end
      it "limitation_text.to_s should be ''" do
        expect(@subgroup.limitation_text).to be_nil
        expect(@subgroup.limitation_text.to_s).to eq("")
      end
      it "name.to_s should be ''" do
        expect(@subgroup.name).to be_an_instance_of(Migel::Util::Multilingual)
        expect(@subgroup.name.to_s).to eq("")
      end
      it "name.xx should be nil" do
        expect(@subgroup.name.de).to be_nil
        expect(@subgroup.name.fr).to be_nil
        expect(@subgroup.name.en).to be_nil
      end
      it "structural_ancestors should be [group]" do
        expect(@subgroup.structural_ancestors("app")).to eq([@group])
      end
      it "pointer should be 'pointer'" do
        expect(@subgroup.pointer).to eq("pointer")
      end
      it "items should be nil" do
        expect(@subgroup.items).to be_nil
      end
      it "product_text should be nil" do
        expect(@subgroup.product_text).to be_nil
      end
      it "respond_to? should have two arguments" do
        expect(@subgroup.respond_to?(:name, "hogehoge")).to be true
      end
    end

    limitation_text = "limitation text"
    language = "de"
    describe Subgroup, "when limitation_text is updated" do
      before do
        @group = Group.new(group_code)
        @subgroup = Subgroup.new(subgroup_code)
        @group.subgroups << @subgroup
        @subgroup.group = @group
        @subgroup.update_limitation_text(limitation_text, language)
      end
      it "limitation_text.de should be '#{limitation_text}'" do
        expect(@subgroup.limitation_text).to be_an_instance_of(Migel::Util::Multilingual)
        expect(@subgroup.limitation_text.de).to eq("limitation text")
        expect(@subgroup.limitation_text.to_s).to eq("limitation text")
        expect(@subgroup.limitation_text.en).to eq("limitation text")
        expect(@subgroup.limitation_text.fr).to be_nil
      end
    end

    describe Subgroup, "when name is updated" do
      before do
        @group = Group.new(group_code)
        @subgroup = Subgroup.new(subgroup_code)
        @group.subgroups << @subgroup
        @subgroup.group = @group

        @subgroup.name.de = "name.de"
        @subgroup.name.fr = "name.fr"
      end
      it "name.de should be 'name.de'" do
        expect(@subgroup.name.de).to eq("name.de")
        expect(@subgroup.name.en).to eq("name.de")
        expect(@subgroup.name.fr).to eq("name.fr")
        expect(@subgroup.de).to eq("name.de")
        expect(@subgroup.en).to eq("name.de")
        expect(@subgroup.fr).to eq("name.fr")
      end
    end
  end # Model
end # Migel
