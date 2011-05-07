require 'mm-paginate'


MongoMapper.setup(YAML.load_file(Rails.root.join('config', 'database.yml')),
                  Rails.env, { :logger => Rails.logger, :passenger => false })
if ENV[‘MONGOHQ_URL’]
  MongoMapper.config = {RAILS_ENV => {‘uri’ => ENV[‘MONGOHQ_URL’]}}
else
  MongoMapper.config = {RAILS_ENV => {‘uri’ => ‘mongodb://admin:admin@flame.mongohq.com:27090/shapado-development’}}
end

MongoMapperExt.init

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end

Dir.glob("#{RAILS_ROOT}/app/models/**/*.rb") do |model_path|
  File.basename(model_path, ".rb").classify.constantize
end

# HACK: do not create indexes on every request
module MongoMapper::Plugins::Indexes::ClassMethods
  def ensure_index(*args)
  end
end


Dir.glob("#{RAILS_ROOT}/app/javascripts/**/*.js") do |js_path|
  code = File.read(js_path)
  name = File.basename(js_path, ".js")

  # HACK: looks like ruby driver doesn't support this
  MongoMapper.database.eval("db.system.js.save({_id: '#{name}', value: #{code}})")
end

require 'support/versionable'
