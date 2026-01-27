# frozen_string_literal: true

require 'spec_helper'
require 'solr_wrapper'
require 'faraday'
require 'json'
require 'fileutils'
require 'securerandom'

RSpec.describe 'integration with solr' do
  let(:solr) { @solr }
  let(:collection) { @collection }

  before(:all) do
    @solr = SolrWrapper::Instance.new port: nil, version: ENV.fetch('SOLR_VERSION', '9.10.0')
    @solr.send(:extract)
    solr_dir = @solr.instance_dir
    test_solr_xml = File.expand_path('../solr/solr.xml', __dir__)
    solr_xml = File.join(solr_dir, 'server/solr/solr.xml')
    contrib_dir = File.join(solr_dir, 'solr-contrib')
    FileUtils.cp test_solr_xml, solr_xml
    FileUtils.mkdir contrib_dir unless File.exist? contrib_dir
    FileUtils.cp Dir.glob(File.join(solr_dir, 'contrib', 'analysis-extras', '**', '*.jar')), contrib_dir
    FileUtils.cp Dir.glob(File.join(solr_dir, 'modules', 'analysis-extras', '**', '*.jar')), contrib_dir
    FileUtils.cp Dir.glob(File.expand_path('../../plugins/*', __dir__)), contrib_dir

    log4jxml = File.join(solr_dir, 'server', 'resources', 'log4j2.xml')

    FileUtils.cp log4jxml, "#{log4jxml}.bak"
    log4j = File.read(log4jxml).gsub('<Async', '<').gsub('</Async', '</')
    File.open(log4jxml, 'w') do |f|
      f.write(log4j)
    end

    @solr.start
  end

  after(:all) do
    @solr.stop

    FileUtils.mv "#{@solr.instance_dir}/server/resources/log4j2.xml.bak",
                 "#{@solr.instance_dir}/server/resources/log4j2.xml"
  end

  around(:example) do |example|
    solr.with_collection(name: File.basename(dir), dir: dir) do |collection|
      @collection = collection
      example.run
    end
  end

  shared_examples 'works in solr' do
    let(:client) do
      Faraday.new("#{solr.url}#{collection}/")
    end

    let(:log_response) do
      client.get('/solr/admin/info/logging?wt=json&since=0&rows=1000').body.to_s
    end

    let(:log) do
      JSON.parse(log_response)['history']['docs'].select do |x|
        x['message'] =~ /#{collection}/ || x['core']&.start_with?(collection)
      end
    end

    describe 'x' do
      it 'has a /select' do
        response = client.get 'select?q=*:*'
        expect(response).to be_success
      end

      it 'logs no serious warnings' do
        client.get 'select?q=*:*'
        salient_lines = log.reject do |x|
          x['message'] =~ Regexp.union(/Creating new index/, /deprecated/, /Couldn't add files from/) ||
            x['message'] =~ /enableRemoteStreaming/
        end

        expect(salient_lines).to be_empty, "Found log lines:\n#{salient_lines.map { |x| x['message'] }.join("\n")}"
      end

      it 'logs no deprecations' do
        client.get 'select?q=*:*'
        deprecated_lines = log.select { |x| x['message'] =~ /deprecated/ }
        salient_lines = deprecated_lines.reject { |x| x['message'] =~ /handleSelect/ || x['message'] =~ /Trie/ }
        pending if collection =~ /exhibits_prod/
        expect(salient_lines).to be_empty, "Found log lines:\n#{salient_lines.map { |x| x['message'] }.join("\n")}"
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
