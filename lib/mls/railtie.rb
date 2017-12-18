# See notes from 'active_record/railtie'
require "action_controller/railtie"
require "active_record/railtie"

class MLS::Railtie < Rails::Railtie
  
  config.mls = ActiveSupport::OrderedOptions.new
  
  config.action_dispatch.rescue_responses.merge!(
    "Sunstone::Exception::NotFound"     => :not_found,
    "Sunstone::Exception::Unauthorized" => :conflict,
    "Sunstone::Exception::Gone"         => :gone
  )
  
  initializer 'mls' do |app|
    
    url = app.config.mls.fetch('url') { app.secrets.mls }
    user_agent = []
    user_agent << app.config.mls.fetch('user_agent') {
      app.class.name.split('::')[0..-2].join('::')
    }
    user_agent << "Rails/#{Rails.version}"
    
    
    MLS::Model.establish_connection({
      adapter: 'sunstone',
      url: url,
      user_agent: user_agent.compact.join(' ')
    })

  end
  
end