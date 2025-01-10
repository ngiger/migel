#! /usr/bin/env ruby
# ODDB::SwissindexSpec -- migel -- 07.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../lib", File.dirname(__FILE__))

require "rspec"
require "rspec/mocks"
require "spec_helper"
require "drb"
require "migel/plugin/swissindex"

module Migel
  module Util
    module Swissindex
      describe Swissindex, "ODDB::Swissindex examples" do
        it "search_migel_table should return an array of hash" do
          expected = ["table"]
          @server = Migel::SwissindexMigelPlugin.new(expected)
          allow_any_instance_of(DRbObject).to receive(:session).and_return(@server)
          allow(DRbObject).to receive(:new).and_return(@server)
          allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(expected)
          expect(@server.get_migelid_by_migel_code("migel_code", "de")).to eq(expected)
        end
      end
    end # Swissindex
  end # Util
end # Migel
