# See notes from 'active_record/railtie'
require "action_controller/railtie"

class MLS::Railtie < Rails::Railtie
  
  config.mls = ActiveSupport::OrderedOptions.new
  
  config.action_dispatch.rescue_responses.merge!(
    "Sunstone::Exception::NotFound"     => :not_found,
    "Sunstone::Exception::Unauthorized" => :unauthorized,
    "Sunstone::Exception::Gone"         => :gone
  )
  
  initializer 'mls' do |app|
    
    configs = if app.secrets.mls.is_a?(String)
      h = ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.new(app.secrets.mls).to_hash.symbolize_keys
      h[:api_key] = h.delete(:username)
      if h[:adapter] != 'sunstone'
        h[:use_ssl] = h[:adapter] == 'https'
        h[:adapter] = 'sunstone'
      end
      h
    elsif app.config.mls.fetch('url').is_a?(String)
      ActiveSupport::Deprecation.warn("Using mls.yml has been deprecated. Move to secrets.yml")
      h = ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.new(app.config.mls.fetch('url')).to_hash.symbolize_keys
      h[:api_key] = h.delete(:username)
      if h[:adapter] != 'sunstone'
        h[:use_ssl] = h[:adapter] == 'https'
        h[:adapter] = 'sunstone'
      end
      h
    else
      app.secrets.mls
    end
    

    user_agent = []
    user_agent << app.config.mls.fetch('user_agent') {
      app.class.name.split('::')[0..-2].join('::')
    }
    user_agent << "Rails/#{Rails.version}"
    configs[:user_agent] = user_agent.compact.join(' ')
    
    
    MLS::Model.establish_connection(configs)
  end
  
end