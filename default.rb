gem 'slim-rails'
gem 'lograge'

gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
  gem 'annotate'
end

gem_group :development, :test do
  gem 'fuubar'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'scss_lint', require: false
  gem 'slim_lint', require: false
  gem 'thin'
end

environment 'config.lograge.enabled = true', env: 'production'

rakefile('rubocop.rake') do
  <<-TASK
require 'rubocop/rake_task'
RuboCop::RakeTask.new
  TASK
end

rakefile 'auto_annotate.rake' do
  <<-TASK
  if Rails.env.development?
    Annotate.load_tasks
  end
  TASK
end

file '.rspec', <<-FILE
--format Fuubar
--color
FILE

file '.rubocop.yml', <<-FILE
AllCops:
  RunRailsCops: true
  Exclude:
    - 'bin/*'

Metrics/LineLength:
  Max: 130

Style/Documentation:
  Enabled: false
FILE

rakefile('scss_lint.rake') do
  <<-TASK
require 'scss_lint/rake_task'
SCSSLint::RakeTask.new
  TASK
end

run 'rm app/assets/stylesheets/application.css'
file 'app/assets/stylesheets/application.scss', <<-FILE
//= require_self
FILE

rakefile('slim_lint.rake') do
  <<-TASK
require 'slim_lint/rake_task'
SlimLint::RakeTask.new
  TASK
end

run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.slim', <<-FILE
doctype html
html
  head
    title My App
    meta name='viewport' content='width=device-width, initial-scale=1.0'
    = stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track' => true
    = javascript_include_tag 'application', 'data-turbolinks-track' => true
    = csrf_meta_tags
  body
    = yield
FILE

file '.slim-lint.yml', <<-FILE
 linters:
  LineLength:
    max: 160
FILE

run 'echo "task default: [:rubocop, :scss_lint, :slim_lint]" >> Rakefile'
run 'rm -rf ./test'

after_bundle do
  system 'rubocop --auto-correct --format offenses'
end
