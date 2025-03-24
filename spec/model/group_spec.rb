#! /usr/bin/env ruby
# Migel::Model::GroupSpec -- migel -- 13.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../lib", File.dirname(__FILE__))

require "rspec"
require "migel/model_super"
require "migel/model/group"
require "migel/util/multilingual"
require "odba/drbwrapper"
require "spec_helper"

module Migel
  module Model
    describe Group, "when initialized with migel code 15" do
      before do
        group_code = "15"
        @group = Group.new(group_code)
      end
      it "migel code should be 15" do
        expect(@group.code).to eq("15")
        expect(@group.migel_code).to eq("15")
        expect(@group.pointer_descr).to eq("15")
      end
      it "subgroups should be empty" do
        expect(@group.subgroups).to be_empty
      end
      it "limitation_text.to_s should be ''" do
        expect(@group.limitation_text).to be_nil
        expect(@group.limitation_text.to_s).to eq("")
      end
      it "name.to_s should be ''" do
        expect(@group.name).to be_an_instance_of(Migel::Util::Multilingual)
        expect(@group.name.to_s).to eq("")
      end
      it "name.xx should be nil" do
        expect(@group.name.de).to be_nil
        expect(@group.name.fr).to be_nil
        expect(@group.name.en).to be_nil
      end
      it "parent should be nil" do
        expect(@group.parent).to be_nil
      end
      it "pointer should be 'pointer'" do
        expect(@group.pointer).to eq("pointer")
      end
    end

    describe Group, "when limitation_text is updated" do
      before do
        migel_code = "15"
        limitation_text = "limitation text"
        language = "de"
        @group = Group.new(migel_code)
        @group.update_limitation_text(limitation_text, language)
      end
      it "limitation_text.de should be 'limitation text'" do
        expect(@group.limitation_text).to be_an_instance_of(Migel::Util::Multilingual)
        expect(@group.limitation_text.de).to eq("limitation text")
        expect(@group.limitation_text.to_s).to eq("limitation text")
        expect(@group.limitation_text.en).to eq("limitation text")
        expect(@group.limitation_text.fr).to be_nil
      end
    end

    describe Group, "when name is updated" do
      before do
        migel_code = "15"
        @group = Group.new(migel_code)
        @group.name.de = "name.de"
        @group.name.fr = "name.fr"
      end
      it "name.de should be 'name.de'" do
        expect(@group.name.de).to eq("name.de")
        expect(@group.name.en).to eq("name.de")
        expect(@group.name.fr).to eq("name.fr")
        expect(@group.de).to eq("name.de")
        expect(@group.en).to eq("name.de")
        expect(@group.fr).to eq("name.fr")
      end
    end
  end # Model
end # Migel
