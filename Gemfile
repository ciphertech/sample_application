#Ref:- http://stackoverflow.com/questions/7146560/error-in-the-push-heroku-json-and-ruby-1-9-2
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'

gem 'rails', '3.0.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2', '~> 0.2.6'
gem 'jquery-rails', '>= 0.2.6'
gem 'devise'
gem 'paperclip', '2.4.5'
#gem 'ruby-debug19', :require => 'ruby-debug'
gem "rails3-jquery-autocomplete", "~> 0.9.1"
gem 'will_paginate', '~> 3.0'
gem 'acts_as_tree'
gem 'mechanize'
gem 'paperclip-meta'
gem 'populator'
gem 'faker'
gem 'fakeweb'
gem 'multi_json', '~>1.3.6'
gem 'hpricot'
gem 'gdata_19'
gem 'contacts'
gem 'delayed_job' , '3.0.1'
gem "daemons"
gem 'delayed_job_active_record', '0.3.1' 


group :test, :development do
  gem 'simplecov'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'gherkin'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'spork'
  gem 'launchy'    # So you can do Then show me the page
  gem 'rdoc' #for removing depreciation warnings
  gem "rails_code_qa"
end
#gem 'ajaxful_rating', :git => 'git://github.com/edgarjs/ajaxful-rating.git', :branch => "rails3"
gem "acts_as_rateable", :git => "git://github.com/anton-zaytsev/acts_as_rateable.git"


# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
