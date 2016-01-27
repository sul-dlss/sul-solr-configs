require 'spec_helper'

describe 'solrconfig.xml' do
  shared_examples 'a solr cloud-ready solrconfig' do
    it 'is valid XML' do
      expect(subject.errors).to be_empty
    end

    it 'has an updatelog' do
      expect(subject.xpath('/config/updateHandler/updateLog')).not_to be_empty
    end

    it 'has a real-time get handler' do
      expect(subject.xpath('/config/requestHandler[@name="/get"][@class="solr.RealTimeGetHandler"]')).not_to be_empty
    end

    describe 'replication handler' do
      let(:replication_handler) do
        subject.xpath('/config/requestHandler[@name="/replication"][@class="solr.ReplicationHandler"]')
      end

      it 'has a replication handler' do
        expect(replication_handler).not_to be_empty
      end
    end

    it 'has jmx defined' do
      expect(subject.xpath('/config/jmx')).not_to be_empty
    end

    it 'has a luceneMatchVersion on or after 4.4' do
      version = subject.xpath('/config/luceneMatchVersion').text
      expect(version).not_to be_empty
      expect(version).to match(/LUCENE/)
      expect(version).to match(/LUCENE_4[4-9]/).or match(/LUCENE_4_[4-9]/).or match(/LUCENE_4_10/).or match(/LUCENE_5/)
    end
  end

  solr_collections.each do |name|
    describe name do
      subject { Nokogiri::XML(File.read(File.join(name, 'solrconfig.xml'))) }
      include_examples 'a solr cloud-ready solrconfig'
    end
  end
end
