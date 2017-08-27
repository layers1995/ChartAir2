require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ChartAir2
  class Application < Rails::Application

  	config.autoload_paths += Dir["#{config.root}/lib/**/"] # I basically needed this to have helper methods for seeds.rb, it was getting big.
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
