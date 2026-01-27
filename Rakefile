# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--fail-level=W']
end

task default: :spec

task :upconfig, [:collection, :solr_url] do |t, args|
  require 'tempfile'
  require 'faraday'
  require 'json'

  args.with_defaults collection: ENV['collection'],
                     solr_url: ENV.fetch('solr_url', ENV['SOLR_ADMIN_BASE_URL'] || 'http://localhost:8983')
  collection = args[:collection]
  solr_url = args[:solr_url]

  unless File.directory?("./#{collection}")
    warn "Collection directory ./#{collection} does not exist"
    exit 0
  end

  unless File.exist?("./#{collection}/solrconfig.xml")
    warn "Collection ./#{collection} does not have a solrconfig.xml file"
    exit 0
  end

  warn "Packaging collection config: #{collection} ..."

  # Package the new config data
  tmpdir = Dir.mktmpdir
  FileUtils.cp_r("./#{collection}/.", tmpdir)
  FileUtils.cp("#{tmpdir}/schema.xml", "#{tmpdir}/managed-schema") if File.exist?("#{tmpdir}/schema.xml")

  tmpzip = Tempfile.new([collection, '.zip'])
  system("(cd #{tmpdir} && zip -r - *) > #{tmpzip.path}")

  warn 'Uploading config ...'
  # Upload the new config data to Solr
  conn = Faraday.new(solr_url)
  response = conn.post('/solr/admin/configs') do |req|
    req.params['overwrite'] = 'true'
    req.params['cleanup'] = 'true'
    req.params['action'] = 'UPLOAD'
    req.params['name'] = collection
    req.headers['Content-Type'] = 'application/octet-stream'
    req.body = File.read(tmpzip.path)
  end

  unless response.success?
    warn "Response: #{response.status} #{response.body}"
    exit 1
  end

  # Identify + reload any collections using this config
  warn 'Reloading collections ...'

  response = conn.get('/solr/admin/collections', action: 'CLUSTERSTATUS')

  data = JSON.parse(response.body)

  data.dig('cluster', 'collections').select { |_key, config| config['configName'] == collection }.each_key do |col|
    warn " ... #{col}"
    conn.get('/solr/admin/collections', action: 'RELOAD', name: col)
    warn "Response: #{response.status} #{response.body}" unless response.success?
    sleep 10
  end
end
