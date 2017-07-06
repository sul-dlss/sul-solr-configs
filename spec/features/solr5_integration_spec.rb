require 'spec_helper'
require 'solr_wrapper'
require 'hurley'
require 'json'
require 'fileutils'
require 'securerandom'

describe 'integration with solr' do
  let(:solr) { @solr }
  let(:collection) { @collection }

  before(:all) do
    @solr = SolrWrapper::Instance.new port: nil, version: '6.6.0'
    @solr.send(:extract)
    solr_dir = @solr.instance_dir
    test_solr_xml = File.expand_path('../../solr/solr.xml', __FILE__)
    solr_xml = File.join(solr_dir, 'server/solr/solr.xml')
    contrib_dir = File.join(solr_dir, 'solr-contrib')
    FileUtils.cp test_solr_xml, solr_xml
    FileUtils.mkdir contrib_dir unless File.exist? contrib_dir
    FileUtils.cp Dir.glob(File.join(solr_dir, 'contrib', 'analysis-extras', '**', '*.jar')), contrib_dir
    FileUtils.cp Dir.glob(File.expand_path('../../../plugins/*', __FILE__)), contrib_dir

    @solr.start
  end

  after(:all) do
    @solr.stop
  end

  around(:example) do |example|
    solr.with_collection(name: "#{File.basename(dir)}_#{SecureRandom.hex}", dir: dir) do |collection|
      @collection = collection
      example.run
    end
  end

  shared_examples 'works in solr' do
    let(:client) do
      Hurley::Client.new("#{solr.url}#{collection}/")
    end

    let(:log_response) do
      client.get('/solr/admin/info/logging?wt=json&since=0').body
    end

    let(:log) do
      JSON.parse(log_response)['history']['docs'].drop_while { |x| x['message'] !~ /#{collection}/ }
    end

    describe 'x' do
      it 'has a /select' do
        response = client.get 'select?q=*:*'
        expect(response).to be_success
      end

      it 'logs no serious warnings' do
        salient_lines = log.reject { |x| x['message'] =~ /Creating new index/ }
                           .reject { |x| x['message'] =~ /deprecated/ }
                           .reject { |x| x['message'] =~ /no default request handler is registered/ }
                           .reject { |x| x['message'] =~ /Will not work from Solr 7/ }
        expect(salient_lines).to be_empty
      end

      it 'logs no deprecations' do
        salient_lines = log.select { |x| x['message'] =~ /deprecated/ }
        expect(salient_lines).to be_empty
      end
    end
  end

  solr_collections.each do |name|
    describe name do
      let(:dir) { name }
      include_examples 'works in solr'
    end
  end
end
