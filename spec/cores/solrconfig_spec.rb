require 'spec_helper'

describe "solrconfig.xml" do
  shared_examples "a solr cloud-ready solrconfig" do
    it "is valid XML" do
      expect(subject.errors).to be_empty
    end

    it "has an updatelog" do
      expect(subject.xpath("/config/updateHandler/updateLog")).not_to be_empty
    end

    it "has a real-time get handler" do
      expect(subject.xpath('/config/requestHandler[@name="/get"][@class="solr.RealTimeGetHandler"]')).not_to be_empty
    end

    it "has a replication handler" do
      expect(subject.xpath('/config/requestHandler[@name="/replication"][@class="solr.ReplicationHandler"]')).not_to be_empty
    end

    it "has admin handlers defined" do
      expect(subject.xpath('/config/requestHandler[@name="/admin/"]')).not_to be_empty
    end
    
    it "has jmx defined" do
      expect(subject.xpath('/config/jmx')).not_to be_empty
    end
  end

  solr_collections.each do |name|
    describe name do
      subject { Nokogiri::XML(File.read(File.join(name, "solrconfig.xml"))) }
      include_examples "a solr cloud-ready solrconfig"
    end
  end
end
