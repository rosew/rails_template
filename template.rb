# Function Source: http://www.rutionrails.com/blog/2016/7/8/regarding-rails-templates-1
def render_file(path)
  file = IO.read(path)
end

# Available commands and docs
# https://guides.rubyonrails.org/rails_application_templates.html
# https://apidock.com/rails/v6.0.0/Rails/Generators/AppGenerator
# https://www.rubydoc.info/github/wycats/thor/Thor/Actions
# https://guides.rubyonrails.org/generators.html
# https://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb
# https://github.com/rails/rails/blob/master/railties/lib/rails/generators/named_base.rb

# Useful variables
# app_name - snake case app name
# app_const_base - App name capitalized
# destination_root - path to the app
template_root = File.dirname path # path to the template directory

# Add localhost setting to the database config so it plays nice with my postgres setup
inside 'config' do
  ['development', 'test'].each do |env_name|
    # Note: inject_into_file requires force: true when injecting the same content in multiple locations
    inject_into_file 'database.yml', force: true, after: "database: #{app_name}_#{env_name}\n" do 
      <<-RUBY
  host: localhost
      RUBY
    end
  end
end

# Copy any assets
directory "#{template_root}/app/assets", "app/assets"
directory "#{template_root}/app/javascript/packs", "app/javascript/packs"
directory "#{template_root}/app/views/application", "app/views/application"

# Generate a new application layout
# Note this template assumes device will be installed
remove_file "app/views/layouts/application.html.erb"
template "#{template_root}/app/views/layouts/application.html.erb.tt", "app/views/layouts/application.html.erb"
template "#{template_root}/app/views/layouts/_flash.html.erb.tt", "app/views/layouts/_flash.html.erb"
template "#{template_root}/app/views/layouts/_update_flash.js.erb.tt", "app/views/layouts/_update_flash.js.erb"

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
route "root to: 'high_voltage/pages#show', id: 'start'"

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

# Modify the default scaffold templates & create some alternative scaffold templates
# Note - directory command would not copy without trying to parse the .tt files 
empty_directory "lib/templates"
empty_directory "lib/generators"
run "cp -r #{template_root}/lib/templates/* lib/templates"
run "cp -r #{template_root}/lib/generators/* lib/generators"

environment do
  <<-RUBY
    # Turn off the default stylesheet generated by scaffold
    # Other options @ https://github.com/rails/rails/blob/master/railties/lib/rails/generators/rails/scaffold/scaffold_generator.rb
    config.generators do |g|
      g.scaffold_stylesheet false
    end
  RUBY
end

# Get an initial scaffold set up so there's a functioning landing page for registered users
def get_scaffold_type
  scaffold_type_select = ask("
  What scaffold would you like to start with?
    A for ajax_scaffold
    S for scaffold
  Enter: ")
  
  case scaffold_type_select
  when "A"
    "ajax_scaffold"
  else
    "scaffold"
  end
end
scaffold_type = get_scaffold_type

model_name = ask("
  Enter the name of your first model (ie Item): ")

model_attributes = ask("
  Enter the attribute pairs for the model (ie name:string description:text).
  The first two non-password attributes will be in the index table.
  Enter:  ")

generate "#{scaffold_type} #{model_name} #{model_attributes}"

# Set the registered user home page
route "
  authenticated :user do
    root to: \"#{model_name.pluralize.underscore}#index\", as: :user_root
  end
"

# Authorization
gem 'pundit'

# Other useful gems
gem 'sendgrid-ruby' # Sendgrid for sending email

