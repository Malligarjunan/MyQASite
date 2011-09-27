require 'mm-paginate'

MongoMapper.connection = Mongo::Connection.new('flame.mongohq.com', 27090, { :logger => Rails.logger })
MongoMapper.database = 'shapado-development'
MongoMapper.database.authenticate('admin', 'admin')


MongoMapperExt.init

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect_to_master if forked
  end
end

Dir.glob("#{RAILS_ROOT}/app/models/**/*.rb") do |model_path|
  File.basename(model_path, ".rb").classify.constantize
end


Dir.glob("#{RAILS_ROOT}/app/javascripts/**/*.js") do |js_path|
  code = File.read(js_path)
  name = File.basename(js_path, ".js")

  # HACK: looks like ruby driver doesn't support this
  MongoMapper.database.eval("db.system.js.save({_id: '#{name}', value: #{code}})")
end

require 'support/versionable'
