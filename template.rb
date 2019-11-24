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

inside 'app/helpers' do
  inject_into_file 'application_helper.rb', after: "module ApplicationHelper\n" do
    <<-RUBY

  def alert_colors(key)
    case key
    when "alert"
      "ba b--red red"
    when "notice"
      "ba b--blue blue"
    else
      "bg-light-gray navy"
    end
  end

    RUBY
  end
end

# Setup static pages
gem 'high_voltage' # Static pages
empty_directory "app/views/pages"
template "#{template_root}/app/views/pages/privacy.html.erb.tt", "app/views/pages/privacy.html.erb"
template "#{template_root}/app/views/pages/terms.html.erb.tt", "app/views/pages/terms.html.erb"
template "#{template_root}/app/views/pages/start.html.erb.tt", "app/views/pages/start.html.erb"

# Set the homepage to the static start page
inside 'config' do
  inject_into_file 'routes.rb', after: "Rails.application.routes.draw do\n" do 
    <<-RUBY
  root to: "high_voltage/pages#show", id: 'start'
    RUBY
  end
end

# Authentication
gem 'devise'
generate "devise:install"
generate "devise User"
directory "#{template_root}/app/views/devise", "app/views/devise"
environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
environment "config.action_mailer.default_url_options = { host: ENV['DOMAIN_NAME'], port: 3000 }", env: 'production'

# Add confirmable and trackable to my devise model
gsub_file "app/models/user.rb", "devise", "devise :confirmable, :trackable,"
Dir.glob('db/migrate/*_create_users.rb').each do |file_name|
  gsub_file file_name, "# t.integer  :sign_in_count", "t.integer  :sign_in_count"
  gsub_file file_name, "# t.datetime :current_sign_in_at", "t.datetime :current_sign_in_at"
  gsub_file file_name, "# t.datetime :last_sign_in_at", "t.datetime :last_sign_in_at"
  gsub_file file_name, "# t.inet     :current_sign_in_ip", "t.inet     :current_sign_in_ip"
  gsub_file file_name, "# t.inet     :last_sign_in_ip", "t.inet     :last_sign_in_ip"
  gsub_file file_name, "# t.string   :confirmation_token", "t.string   :confirmation_token"
  gsub_file file_name, "# t.datetime :confirmed_at", "t.datetime :confirmed_at"
  gsub_file file_name, "# t.datetime :confirmation_sent_at", "t.datetime :confirmation_sent_at"
  gsub_file file_name, "# t.string   :unconfirmed_email", "t.string   :unconfirmed_email"
  gsub_file file_name, "# add_index :users, :confirmation_token", "add_index :users, :confirmation_token"
end

gem 'pundit' # Authorization

# Other useful gems
gem 'sendgrid-ruby' # Sendgrid for sending email

