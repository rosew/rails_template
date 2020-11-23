# rails_template
A template for creating a default rails app with some base configurations.

Create a rails app with:

```
rails new <app_name> -m rails_template/template.rb --database=postgresql
```

## Credentials

If using the api add the following to your credentials file:

```
devise:
  jwt_secret_key: <key generated using: rails secret>
```

### Saving Credentials
To save credentials run:

EDITOR="vi" rails credentials:edit   

Or for a specific environment use:

EDITOR="vi" rails credentials:edit --environment <environment name ie production, development, test>
	
For more details run: rails credentials:help

Access credentials with: Rails.application.credentials.<credential name>

### Production Credentials

Encrypted credentials are decrypted using either:

- config/master.key
- the env variable RAILS_MASTER_KEY set to the contents of config/master.key

Note: *NEVER* check into source control config/master.key

## Sources

Tachyons: https://tachyons.io/

JWT API authorization is based on this article:
https://medium.com/@brentkearney/json-web-token-jwt-and-html-logins-with-devise-and-ruby-on-rails-5-9d5e8195193d

