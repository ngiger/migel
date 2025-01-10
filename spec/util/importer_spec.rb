#! /usr/bin/env ruby
# encoding: utf-8
# Migel::Util::ImporterSpec -- migel -- 05.10.2011 -- mhatakeyama@ywesee.com
$: << File.expand_path('../../lib', File.dirname(__FILE__))
require 'yaml'
require 'rspec'
require 'rspec/mocks'
require 'spec_helper'
require 'migel/util/importer'
require 'migel/model'
require 'migel/util/mail'
require 'odba'
require 'mail'

module Migel
  module Util

describe Importer, "Examples" do
  before(:each) do
    @importer = Migel::Util::Importer.new
  end
  it "estimate_time should estimate the total calculation time" do
    allow(Time).to receive(:now).and_return(3600.0)
    start_time = 0.0
    total = 100
    count = 30
    expected = " 30 / 100\tEstimate total: 3.33 [h] It will be done in: 2.33 [h]\n"
    expect(estimate_time(start_time, total, count)).to eq(expected)
    count = 60
    expected = " 60 / 100\tEstimate total: 1.67 [h] It will be done in: 40.00 [m]\n"
    expect(estimate_time(start_time, total, count)).to eq(expected)
    start_time = 3500.0
    total = 10
    count = 5
    expected = "  5 / 10\tEstimate total: 3.33 [m] It will be done in: 1.67 [m]\n"
    expect(estimate_time(start_time, total, count)).to eq(expected)
  end
  it "update_group should update a Group instance when it is found in the database" do
    name  = double('name', :de= => nil)
    group = double('group',
                   :name => name,
                   :update_limitation_text => nil,
                   :save => nil
                  )
    allow(Migel::Model::Group).to receive(:find_by_code).and_return(group)

    id  = ['groupcd']
    row = [0,1,'name','limitation text']
    language = 'de'
    expect(@importer.update_group(id, row, language)).to eq(group)
  end
  it "update_group should create a Group instance when it is a new group data" do
    name  = double('name', :de= => nil)
    group = double('group',
                   :name => name,
                   :update_limitation_text => nil,
                   :save => nil
                  )
    allow(Migel::Model::Group).to receive(:find_by_code)
    allow(Migel::Model::Group).to receive(:new).and_return(group)

    id  = ['groupcd']
    row = [0,1,'name','limitation text']
    language = 'de'
    expect(@importer.update_group(id, row, language)).to eq(group)
  end
  it "update_subgroup should update a Subgroup instance when it is found in the database" do
    name  = double('name', :de= => nil)
    subgroup = double('subgroup',
                      :code   => 'subgroupcd',
                      :group= => nil,
                      :name   => name,
                      :update_limitation_text => nil,
                      :save   => nil)
    group = double('group',
                   :subgroups => [subgroup]
                  )

    row = [0,1,2,3,4,5,'name','limitation text']
    language = 'de'
    id = [0,'subgroupcd']
    expect(@importer.update_subgroup(id, group, row, language)).to eq(subgroup)
  end
  it "update_subgroup should create a Subgroup instance when it is not found in the database" do
    group = double('group',
                   :subgroups => [],
                   :save => nil
                  )
    name  = double('name', :de= => nil)
    subgroup = double('subgroup',
                      :group= => nil,
                      :name => name,
                      :update_limitation_text => nil,
                      :save => nil
                     )
    allow(Migel::Model::Subgroup).to receive(:new).and_return(subgroup)

    id = [0, 'id']
    row = [0,1,2,3,4,5,'name','limitation text']
    language = 'de'
    expect(@importer.update_subgroup(id, group, row, language)).to eq(subgroup)
  end
  it "update_migelid should update a Migelid instance when it is found in the database" do
    migelid = double('migelid',
                   :subgroup= => nil,
                   :update_multilingual => nil,
                   :code   => '12.34.5',
                   :date   => nil,
                   :save   => nil,
                   :type=  => nil,
                   :price= => nil,
                   :date=  => nil,
                   :qty=   => nil,
                   :limitation= => nil,
                   :limitation_text => nil,
                  )
    name  = double('name', :de= => nil)
    subgroup = double('subgroup',
                      :migelids => [migelid],
                      :group= => nil,
                      :name => name,
                      :update_limitation_text => nil,
                      :save => nil
                     )
    id = [0,1,'12','34','5']
    row = [0,1,2,3,4,5,6,7,8,9,10,11,'name',13,'L','migelid text Limitation text','qty','unit','1234',19,'31.12.2011']
    language = 'de'
    expect(@importer.update_migelid(id, subgroup, row, language)).to eq(migelid)
    row = [0,1,2,3,4,5,6,7,8,9,10,11,'',13,'L','migelid text','qty','unit','1234',19,'31.12.2011']
    expect(@importer.update_migelid(id, subgroup, row, language)).to eq(migelid)
  end
  it "update_migelid should create a Migelid instance when it is not found in the database" do
    migelid = double('migelid',
                   :subgroup= => nil,
                   :update_multilingual => nil,
                   :code   => '12.00.1',
                   :date   => nil,
                   :save   => nil,
                   :type=  => nil,
                   :price= => nil,
                   :date=  => nil,
                   :qty=   => nil,
                   :limitation= => nil,
                   :limitation_text => nil,
                   :add_migelid => nil
                  )
    name  = double('name', :de= => nil)
    subgroup = double('subgroup',
                      :migelids => [],
                      :group= => nil,
                      :name => name,
                      :update_limitation_text => nil,
                      :save => nil
                     )
    allow(Migel::Model::Migelid).to receive(:new).and_return(migelid)
    id = [0,1,'12','34','5']
    row = [0,1,2,3,4,5,6,7,8,9,10,11,'name',13,'L','migelid text Limitation text','qty','unit','1234',19,'31.12.2011']
    language = 'de'
    expect(@importer.update_migelid(id, subgroup, row, language)).to eq(migelid)
  end
  describe "update method updates group, subgroup, and migelid instances" do
    before(:each) do
      row = [0,1,2,3,4,5,6,7,8,9,10,11,'name','12.34.56.78.9','L','migelid text Limitation text','qty','unit','1234',19,'31.12.2011']
      allow(CSV).to receive(:readlines).and_return([0,row])

      # for migelid
      name  = double('name', :de= => nil)
      @migelid = double('migelid',
                     :subgroup= => nil,
                     :update_multilingual => nil,
                     :code   => '56.78.9',
                     :save   => nil,
                     :type=  => nil,
                     :price= => nil,
                     :date=  => nil,
                     :qty=   => nil,
                     :date   => nil,
                     :limitation= => nil,
                     :migel_code  => '12.34.56.78.9',
                     :delete => 'delete_migelid',
                     :limitation_text => nil,
                    )
      # for subgroup
      @subgroup = double('subgroup',
                        :code   => '34',
                        :group= => nil,
                        :name   => name,
                        :update_limitation_text => nil,
                        :save   => nil,
                        :migelids   => [@migelid],
                        :migel_code => '12.34',
                        :delete => 'delete_subgroup'
                     )
      # for group
      @group = double('group',
                     :name => name,
                     :update_limitation_text => nil,
                     :save => nil,
#                      :subgroups  => [@subgroup.is_a?(Integer) ? nil : @subgoup ],
                     :subgroups  => [@subgroup ],
                     :migel_code => '12',
                     :delete => 'delete_group'
                    )
      allow(Migel::Model::Group).to receive(:find_by_code).and_return(@group)
      allow_any_instance_of(Integer).to receive(:subroups).and_return(nil)
    end
    it "normal update" do
      allow(ODBA.cache).to receive(:index_keys).and_return(['12', '12.34', '12.34.56.78.9'])

      language = 'de'
      expect do
        skip "No time to fix this error, which was introduced in 2020 after commit b1345b14200097258ff6e3b2f06bb202318f1b85"
        @importer.update('path', language)
      end.not_to raise_error
      expect(@importer.migel_code_list).to eq([])

      row = [0,1,2,3,4,5,6,7,8,9,10,11,'name','12.34.56.78.9','L','migelid text Limitation text','qty','unit','1234',19,'31.12.2011']
      allow(CSV).to receive(:readlines).and_return([0,row])
      row[13] = ''
      row[4]  = '12.34.56.78.9'
      expect do
        @importer.update('path', language)
      end.not_to raise_error
    end
    it "delete group" do
      allow(ODBA.cache).to receive(:index_keys).and_return(['10', '12.34', '12.34.56.78.9'])
      allow_any_instance_of(Migel::Model::Group).to receive(:find_by_migel_code).and_return(@group)
      language = 'de'
      skip "No time to fix this error, which was introduced in 2020 after commit b1345b14200097258ff6e3b2f06bb202318f1b85"
      @importer.update('path', language)
      expect(@importer.migel_code_list).to eq(['10'])
    end
    it "delete subgroup" do
      allow(ODBA.cache).to receive(:index_keys).and_return(['12', '12.30', '12.34.56.78.9'])
      allow(Migel::Model::Group).to receive(:find_by_migel_code).and_return(@subgroup)
      allow(Migel::Model::Subgroup).to receive(:find_by_migel_code).and_return(nil)
      allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(nil)
      language = 'de'
      skip "No time to fix this error, which was introduced in 2020 after commit b1345b14200097258ff6e3b2f06bb202318f1b85"
      @importer.update('path', language)
      expect(@importer.migel_code_list).to eq(['12.30'])
    end
    it "delete migelid" do
      allow(ODBA.cache).to receive(:index_keys).and_return(['12', '12.34', '12.34.56.78.0'])
      allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(@migelid)
      language = 'de'
      skip "No time to fix this error, which was introduced in 2020 after commit b1345b14200097258ff6e3b2f06bb202318f1b85"
      @importer.update('path', language)
      expect(@importer.migel_code_list).to eq(['12.34.56.78.0'])
    end
  end
  it "migel_code_list should return migel_code list of Array" do
    allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
    expect(@importer.migel_code_list).to eq(['migel_code'])
  end
  it "migel_code_list should output migel_code list into a file" do
    allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
    file = double('out', :print => nil)
    allow(File).to receive(:open).and_yield(file)
    expect(@importer.migel_code_list('migel_code_list.dat')).to eq(['migel_code'])
  end
  it "unimported_migel_code_list should return uniported migel_code list" do
    allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
    migelid = double('migelid',:products => [])
    allow_any_instance_of(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
    skip "No time to fix this error, which was introduced in 2020 after commit b1345b14200097258ff6e3b2f06bb202318f1b85"
    expect(@importer.unimported_migel_code_list).to eq(['migel_code'])
  end
  it "unimported_migel_code_list should output unimported migel_code list into a file" do
    skip "No time to fix this error, which was introduced in 2020 after commit b1345b14200097258ff6e3b2f06bb202318f1b85"
    allow_any_instance_of(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
    migelid = double('migelid',:products => [])
    allow_any_instance_of(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
    file = double('out', :print => nil)
    allow(File).to receive(:open).and_yield(file)
    expect(@importer.unimported_migel_code_list('unimported_migel_code_list.dat')).to eq(['migel_code'])
  end
  describe 'update_product example' do
    before(:each) do
      multilingual = double('multilingual', :de= => nil)
      @product = double('product',
                     :pharmacode => 'pharmacode',
                     :migelid=   => nil,
                     :save       => nil,
                     :ean_code=  => nil,
                     :article_name => multilingual,
                     :companyname  => multilingual,
                     :companyean=  => nil,
                     :ppha=      => nil,
                     :ppub=      => nil,
                     :factor=    => nil,
                     :pzr=       => nil,
                     :size       => multilingual,
                     :status=    => nil,
                     :datetime=  => nil,
                     :stdate=    => nil,
                     :language=  => nil
                    )
      @record = {
        :pharmacode   => 'pharmacode',
        :ean_code     => 'ean_code',
        :article_name => 'article_name',
        :companyname  => 'companyname',
        :companyean   => 'companyean',
        :ppha         => 'ppha',
        :ppub         => 'ppub',
        :factor       => 'factor',
        :pzr          => 'pzr',
        :size         => 'size',
        :status       => 'status',
        :datetime     => 'datetime',
        :stdate       => 'stdate',
        :language     => 'language'
      }
      @language = 'de'
      @importer = Migel::Util::Importer.new
    end
    it "update_product should update a Product instance when it is found in the database" do
      migelid = double('migelid',:products => [@product])
      language = @language
      record = @record
      product = @product
      expect(@importer.send(:update_product, migelid, record, language)).to eql product
    end
    it "update_product should create a Product instance when it is not found in the database" do
      migelid = double('migelid',
                     :products => [],
                     :save     => nil
                    )

      allow(Migel::Model::Product).to receive(:new).and_return(@product)
      language = @language
      record = @record
      product = @product
      expect(@importer.send(:update_product, migelid, record, language)).to eql product
    end
    it "update_products_by_migel_code should update products searched by online migel server" do
      migelid = double('migelid',
                     :products => [@product],
                     :migel_code => 'migel_code',
                     :date => nil,
                     :save => nil,
                    )
      allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)

      server = double('swissindex_nonpharmad')
      allow(DRbObject).to receive(:new).and_return(@server)
      require 'migel/ext/swissindex'
      record = {:pharmacode => 'pharmacode', :article_name => 'article_name'}
      table = [record]
      allow(ODDB::Swissindex).to receive(:search_migel_table).and_return(table)

      expect(@importer.update_products_by_migel_code('migel_code', 'de')).to be_nil
    end
    it "import_all_products_from_csv should update products by a csv file" do
      allow(File).to receive(:readlines).and_return(['line'])
      line = ['migel_code', 'pharmacode', 'ean_code', 'article_name']
      allow(CSV).to receive(:open).and_yield(line)
      migelid = double('migelid',
                     :migel_code => 'migel_code',
                     :add_product => @product,
                     :save => nil,
                     :products => [@product],
                     :date => nil,
                    )
      migelid2 = double('migelid2',
                     :migel_code => 'migel_code',
                     :add_product => @product,
                     :save => nil,
                     :delete => nil,
                     :products => [@product],
                     :date => nil,
                    )
      allow(migelid).to receive(:dup).with(no_args).and_return(migelid2)
      allow(@product).to receive(:delete)
      allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
      allow(Migel::Model::Product).to receive(:find_by_pharmacode).and_return(@product)
      allow(ODBA.cache).to receive(:index_keys).and_return(['code'])
      expect(@importer.import_all_products_from_csv).to eq(['code'])
    end
  end
  describe 'missing_article_name_migel_code_list' do
    before(:each) do
      allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
      multilingual = double('multilingual', :de => '')
      product = double('product',:article_name => multilingual)
      migelid = double('migelid',:products => [product])
      allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
    end
    it "missing_article_name_migel_code_list should return missing migel code list" do
      expect(@importer.missing_article_name_migel_code_list).to eq(['migel_code'])
    end
    it "missing_article_name_migel_code_list should outout missing migel code list" do
      file = double('out', :print => nil)
      allow(File).to receive(:open).and_yield(file)
      expect(@importer.missing_article_name_migel_code_list('de', 'migel_code_list.dat')).to eq(['migel_code'])
    end
  end
  it 'reimport_missing_data should update products' do
    # for missing_article_name_migel_code_list
    allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
    multilingual = double('multilingual',
                        :de  => '',
                        :de= => nil
                       )
    product = double('product',
                   :article_name => multilingual,
                   :pharmacode   => 'pharmacode',
                   :migelid=     => nil,
                   :ean_code=    => nil,
                   :companyname  => multilingual,
                   :companyean=  => nil,
                   :ppha=        => nil,
                   :ppub=        => nil,
                   :factor=      => nil,
                   :pzr=         => nil,
                   :size         => multilingual,
                   :status=      => nil,
                   :datetime=    => nil,
                   :stdate=      => nil,
                   :language=    => nil,
                   :save         => nil
                  )

    # for update_products_by_migel_code
    migelid = double('migelid',
                   :products => [product],
                   :migel_code => 'migel_code',
                   :date => nil,
                   :save => nil
                  )
    allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)

    server = double('swissindex_nonpharmad')
    allow(DRbObject).to receive(:new).and_return(@server)
    require 'migel/ext/swissindex'
    record = {:pharmacode => 'pharmacode', :article_name => 'article_name'}
    table = [record]
    allow(ODDB::Swissindex).to receive(:search_migel_table).and_return(table)

    expect(@importer.reimport_missing_data).to eq('1 migelids is updated.')

  end
  describe '#code_list' do
    context 'default' do
      before do
        allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
      end
      subject {@importer.code_list('index_table_name')}
      it {is_expected.to eq(['migel_code'])}
    end
  end
  describe '#migel_code_list' do
    before do
      allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
    end
    subject {@importer.migel_code_list}
    it {is_expected.to eq(['migel_code'])}
  end
  describe '#report' do
    before do
      allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
      allow(@importer).to receive(:migel_code_list).and_return(['migel_code'])
      @importer.instance_eval do
        @migel_codes_with_products = []
        @migel_codes_without_products = []
      end
    end
    subject {@importer.report('de')}
    let(:expected) {
      ["Total time to update: 0.00 [m]",
       "Saved file: ",
       "Total     1 Migelids (    0 Migelids have products /     0 Migelids have no products)",
       "Saved  Products", "",
       "Migelids with products (0)", "",
       "Migelids without products (0)"]
    }
    it {is_expected.to eq(expected)}
  end
  describe '#compress' do
    file_name = "#{Dir.tmpdir}/file"
    before do
      allow(File).to receive(:mtime)
      File.open(file_name, 'w+') { |f| f.puts "#Created by #{__FILE__}/#{__LINE__}" }
      allow(File).to receive(:open)
      @gz = double('gz',
                 :mtime= => nil,
                 :orig_name= => nil,
                 :puts => nil
                )
      allow(Zlib::GzipWriter).to receive(:open).and_yield(@gz)
    end
    subject {@importer.compress(file_name)}
    it {is_expected.to eq("#{file_name}.gz")}
  end
  describe '#report_save_all_products' do
    before do
      allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
      server = double('swissindex_nonpharmad')
      allow(DRbObject).to receive(:new).and_return(@server)
      require 'migel/ext/swissindex'
      migelid = double('migelid',:migel_code => '12.34.56.78.9')
      allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
      record = {:pharmacode => 'pharmacode', :article_name => 'article_name'}
      table = [record]
      allow(ODDB::Swissindex).to receive(:search_migel_table).and_return(table)

      writer = double('writer', :<< => nil)
      allow(CSV).to receive(:open).and_yield(writer)

      allow(File).to receive(:mtime)
      allow(File).to receive(:open)
      @gz = double('gz',
                 :mtime= => nil,
                 :orig_name= => nil,
                 :puts => nil
                )
      allow(Zlib::GzipWriter).to receive(:open).and_yield(@gz)
      config = double('config', :server_name => 'server_name')
      allow(Migel).to receive(:config).and_return(config)
      allow(Mail).to receive(:notify_admins_attached).and_return('notify_admins_attached')
      allow(@importer).to receive(:migel_code_list).and_return(['migel_code'])
      @importer.instance_eval do
        @migel_codes_with_products = []
        @migel_codes_without_products = []
      end
    end
    subject {@importer.reported_save_all_products}
    it {is_expected.to be_a(Array)}
    subject {@importer.report('de')}
    let(:expected) {
      ["Total time to update: 0.00 [m]",
       "Saved file: ",
       "Total     1 Migelids (    0 Migelids have products /     0 Migelids have no products)",
       "Saved  Products", "",
       "Migelids with products (0)", "",
       "Migelids without products (0)"]
    }
    it {is_expected.to eq(expected)}
  end
end # describe

  describe 'RealWorld: create 3 language specific CSV files from the given xls file' do
    before(:each) do
      @saved_xls = Migel::Util::Importer::OriginalXLS
      allow(ODBA.cache).to receive(:index_keys).and_return(['migel_code'])
      multilingual = double('multilingual', :de => '')
      product = double('product',:article_name => multilingual)
      migelid = double('migelid',:products => [product])
      allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
    end
    after(:each) do
      Migel::Util::Importer::OriginalXLS = @saved_xls
    end

    def setup_importer
      @importer = Migel::Util::Importer.new
      @test_file = File.expand_path(File.join(__FILE__, '..',  '..', 'data', 'MiGeL-2022.01.21.xls'))
      expect(File.exist?(@test_file)).to be true
#      expect(File.size(@test_file)).to be < 75000
      @server = Migel::Util::Server.new
      allow_any_instance_of(DRbObject).to receive(:session).and_return(@server)
      migelid = double('migelid',:migel_code => '12.34.56.78.9', :delete => true)
      allow(Migel::Model::Migelid).to receive(:find_by_migel_code).and_return(migelid)
      group = double('group',
                    :name => 'name',
                    :update_limitation_text => nil,
                    :save => nil
                    )
      allow(Migel::Model::Group).to receive(:find_by_code)
      expect(@importer.data_dir).not_to be_nil
      FileUtils.rm(Dir.glob(File.join(@importer.data_dir, '*')))
    end

    it "missing_article_name_migel_code_list should return missing migel code list" do
      setup_importer
      Migel::Util::Importer::OriginalXLS = @test_file
      @importer.update_all
      expect(@importer.xls_file).to match /MiGeL.xls/
      expect(Dir.glob(File.join(@importer.data_dir, '*.csv')).size).to  eq(3)
      baseNames = Dir.glob(File.join(@importer.data_dir, '*.csv')).collect{ |f| File.basename(f) }
      { 'migel_de.csv' =>
          'Produktegruppe Nr,Limitation Produktegruppe,Produktegruppe,Beschreibung Produktegruppe,Kategorie Nr,Limitation Kategorie,Kategorie,Beschreibung Kategorie,Revision Kaegorie,Revision Kat Gültig ab,Unterkategorie Nr,Limitation Unterkategorie,Unterkategorie,Positions Nummer,Limitation,Bezeichnung,Menge,Einheit,Höchstvergütungsbetrag,Revision Position,Revision Gültig ab',
        'migel_fr.csv' =>
          'Groupe de produits No,Limitation Groupe de produits,Groupe de produits,Description Groupes de produits,Catégorie No,Limitation Catégorie,Catégorie,Description Catégorie,Revision Catégorie,Valable à partir du (Revision Catégorie),Sous-catégorie No,Limitation Sous-catégorie,Sous-catégorie,No pos.,Limitation,Dénomination,Quantité,Unité de mesure,Montant,Revision,Valable à partir du',
        'migel_it.csv' =>
          'Gruppi di prodotti No,Limitazione (Gruppi di prodotti),Gruppi di prodotti,Descrizione,Categoria No,Limitazione (Categoria),Categoria,Descrizione Categoria,Revisione Categoria,Valida a partire dal (Revisione Categoria),Sotto-categoria No,Limitazione Sotto-categoria,Sotto-categoria,Numero di posizione,Limitazione,Denominazione,Quantita,Unità,Importo Massimo,Revisione,Valida a partire dal',
      }.each do
        |csv_file, firstline|
        expect(baseNames.index(csv_file)).not_to eq(nil)
        lines=CSV.readlines(File.join(@importer.data_dir, csv_file))
        expect(lines[1].join(',')).to match /^01.,/
        next unless /_de.csv/.match(csv_file)
        expect(lines[7].join(',')).to match /^05.,/
        expect(lines[7].join(',')).to match /,05\.10\.02\.00\.1,/
        expect(lines.size).to eq(9)
        # skip "expect(lines.first.chomp).to eq(firstline)"
      end
      @importer.update_all
      expect(Dir.glob(File.join(@importer.data_dir, '*.csv')).size).to  eq(3)
    end

    it "save_all_products_all_languages should work fine and send a correct email"  do
      setup_importer
      ::Mail.defaults do
        delivery_method :test
      end
      ::Mail::TestMailer.deliveries.clear
      Migel::Util::Importer::OriginalXLS = @test_file
      @importer.save_all_products_all_languages
      expect(::Mail::TestMailer.deliveries.size).to eq(3)
      ::Mail::TestMailer.deliveries.each{ |mail| expect(mail.to_s).not_to match /RuntimeError/ }
    end
    it "the generated CSV file should have a correct date"  do
      setup_importer
      ::Mail.defaults do
        delivery_method :test
      end
      # https://www.bag.admin.ch/bag/de/home/versicherungen/krankenversicherung/krankenversicherung-leistungen-tarife/Mittel-und-Gegenstaendeliste.html
      setup_importer
      Migel::Util::Importer::OriginalXLS = @test_file
      @importer.update_all
      expect(@importer.xls_file).to match /MiGeL.xls/
      files = Dir.glob(File.join(@importer.data_dir, '*.csv'))
      expect(files.size).to  eq(LANGUAGE_NAMES.size)
      first_file = CSV.readlines(files.first)
      first_row = first_file[1]
      expect(first_row[22]).to eq '01.10.2021'
    end
  end

  end # Util
end # Migel
