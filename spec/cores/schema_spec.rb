require 'spec_helper'

describe "schema.xml" do
  shared_examples "a solr cloud-ready schema" do
    it "is valid XML" do
      expect(subject.errors).to be_empty
    end

    it "has a _version_ field" do
      expect(subject.xpath('/schema/fields/field[@name="_version_"]')).not_to be_empty
    end
  end

  solr_collections.each do |name|
    describe name do
      subject do
        Dir.chdir(name) do
          Nokogiri::XML(File.read(File.join("schema.xml")), &:xinclude)
        end
      end
      include_examples "a solr cloud-ready schema"
    end
  end
end
