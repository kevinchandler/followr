source 'https://rubygems.org'

ruby '2.3.0'

gem 'rails', '4.2.1'
gem 'sinatra', :require => nil

# Assets
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'sass-rails', '~> 4.0.3'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'turbolinks'

# Servers
gem 'unicorn'
gem 'pg'
gem 'redis'
gem 'rails_12factor', group: :production

# Workers
gem 'sidekiq'
gem 'sidetiq'

# Monitoring
gem 'newrelic_rpm'
gem 'airbrake'

# Twitter integration
gem 'twitter'
gem 'omniauth'
gem 'omniauth-twitter'

gem 'attr_encrypted'
gem 'draper', '~> 1.3'

# Admin
gem 'activeadmin', '~> 1.0.0.pre1'
gem 'devise'

# Charting
gem 'groupdate'
gem 'chartkick'

# Debugging
group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem "better_errors"
  gem "binding_of_caller"

  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'pry-byebug', '~> 1.3.3'

  # Remote debugging – connect with pry-remote command
  gem 'pry-remote'

	gem 'pry'
	gem 'pry-nav'
	gem 'rspec-rails', '~> 3.0'
end
