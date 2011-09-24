source 'http://rubygems.org'

gem 'rake', '0.9.2'
gem 'rails', '3.0.10'
#gem 'mysql2', '0.2.6'
gem 'mysql'
gem 'spork', '~> 0.9.0.rc'

# Deploy with Capistrano
gem 'capistrano', '2.8.0'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem "webrat"
#  gem 'activesupport', '>=3.0.9'
#  gem 'activemodel', '>=3.0.9'
#  gem 'actionpack', '>=3.0.9'
  gem 'email_spec', '1.1.1'
#  gem 'sqlite3-ruby', '1.3.2', :require => 'sqlite3'
  gem 'capybara', ">1.0.0"
  gem 'culerity', '0.2.15'
  gem 'celerity', '0.8.9', :require => nil
  gem 'database_cleaner', '0.6.0'
  gem 'cucumber-rails', "1.0.2"
  gem 'cucumber', "1.0.2"
  gem 'launchy', "0.4.0"
  gem 'factory_girl_rails', '1.0.1'
  gem "rspec-rails", "2.5.0"
  gem 'timecop', '0.3.5'
  gem 'escape_utils'
end

# To setup rpsec and cucumber:
# rails g rspec:install
# rails g cucumber:install --rspec --capybara
#
# To ge the Mac Firefox to work (per google search on problem):
# cd /Applications/Firfox.app/Contents/MacOS
# mv firefox-bin firefox-bin.original
# ditto --arch i386 firefox-bin.original firefox-bin
# 
