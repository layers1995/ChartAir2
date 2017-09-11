# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.compress = true
Rails.application.config.assets.js_compressor = :uglifier

#stylesheets
Rails.application.config.assets.precompile += %w( sessions.css )
Rails.application.config.assets.precompile += %w( faq.css )
Rails.application.config.assets.precompile += %w( main.css )
Rails.application.config.assets.precompile += %w( base.css )
Rails.application.config.assets.precompile += %w( plan_trip.css )
Rails.application.config.assets.precompile += %w( plan_trip_results.css )

#images
Rails.application.config.assets.precompile += %w(sky3.jpg)
Rails.application.config.assets.precompile += %w(arrowImage.png)
Rails.application.config.assets.precompile += %w(browserlogo_icon.ico)
Rails.application.config.assets.precompile += %w(chartairWhiteLogo.png)
Rails.application.config.assets.precompile += %w(clare.jpg)
Rails.application.config.assets.precompile += %w(flagIcon.png)
Rails.application.config.assets.precompile += %w(logan.jpg)
Rails.application.config.assets.precompile += %w(madison.jpg)
Rails.application.config.assets.precompile += %w(olivia.jpg)
Rails.application.config.assets.precompile += %w(logoBright4.png)

#javascripts
Rails.application.config.assets.precompile += %w( addPlane.js )
Rails.application.config.assets.precompile += %w( planTrip.js )
Rails.application.config.assets.precompile += %w( results.js )

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
