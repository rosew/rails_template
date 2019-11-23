# Function Source: http://www.rutionrails.com/blog/2016/7/8/regarding-rails-templates-1
def render_file(path)
  file = IO.read(path)
end

# Available commands and docs
# https://apidock.com/rails/v6.0.0/Rails/Generators/AppGenerator
# https://www.rubydoc.info/github/wycats/thor/Thor/Actions

# Useful variables
# app_name - snake case app name
# app_const_base - App name capitalized
# destination_root - path to the app
template_root = File.dirname path # path to the template directory

# Add localhost setting to the database config so it plays nice with my postgres setup
inside 'config' do
  ['development', 'test'].each do |env_name|
    inject_into_file 'database.yml', after: "database: #{app_name}_#{env_name}\n" do 
      <<-RUBY
  host: localhost
      RUBY
    end
  end
end

# Copy any assets
directory "#{template_root}/app/assets", "app/assets"

# Generate a new application layout
# Note this template assumes device will be installed
remove_file "app/views/layouts/application.html.erb"
template "#{template_root}/app/views/layouts/application.html.erb.tt", "app/views/layouts/application.html.erb"


create_file 'database.yml', "#{template_root}/config/database.yml"

gem 'high_voltage' # Static pages

gem "font-awesome-rails" # Icons

gem 'devise' # Authentication
generate "devise:install"
generate "devise User"
environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
environment "config.action_mailer.default_url_options = { host: ENV['DOMAIN_NAME'], port: 3000 }", env: 'production'

gem 'pundit' # Authorization
gem 'sendgrid-ruby' # Sendgrid for sending email

