require 'bundler'

# to test with Docker
alias :origin_yes? :yes?
def yes?(q)
  origin_yes?(q) || ENV["TESTING_APP_TEMPLATE"]
end

run 'rm Gemfile.lock' if yes?("Did you install Rails to this directory via bundler?")
run 'rm -rf test'
run %Q(echo "\nvendor/bundle\n" .gitignore)
uncomment_lines 'Gemfile', 'therubyracer'
comment_lines 'Gemfile', 'spring'
comment_lines 'Gemfile', 'sqlite3'

gem 'slim-rails'
gem 'bower-rails'

if yes?("Would you like to use devise?")
  gem 'devise'
  gem 'cancancan' if yes?("Would you like to use cancancan?")
end

gem_group :development, :test do
  gem 'sqlite3'
  gem 'spring'
  gem 'rspec-rails'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-spring'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'terminal-notifier-guard'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
end

gem_group :deployment do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'capistrano_colors'
end

gem_group :production do
  gem 'pg'
  if yes?("Would you like to use Heroku?")
    gem 'rails_12factor'
  else
    gem 'unicorn'
  end
end

Bundler.with_clean_env do
  run 'bundle install --without production --path vendor/bundle'
end

run 'bundle exec spring binstub'
run 'bin/rails generate rspec:install'
run "bundle exec guard init rspec"

run 'bin/rails generate bower_rails:initialize'
if yes?("Would you like to use twitter-bootstrap?")
  run %Q(echo "\nasset 'bootstrap'" >> Bowerfile)
  run %Q(echo "\n*= require bootstrap" >> app/assets/stylesheets/application.css)
  run %Q(echo "\n//= require bootstrap" >> app/assets/javascripts/application.js)
end
if yes?("Would you like to use angular.js?")
  run %Q(echo "\nasset 'angular'" >> Bowerfile)
end
inject_into_file 'config/application.rb',
  "\n\s\s\s\sconfig.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')",
  :after => "class Application < Rails::Application"
run "bin/rake bower:install['--allow-root']"
run 'bin/rake db:migrate'

git :init
git add: "."
git commit: %Q(-m "initial commit")
