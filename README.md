# Carrierwave::TrueVault

This gem adds support for [TrueVault](https://truevault.com) to the CarrierWave.

## Installation

Add this line to your application's Gemfile:

    gem 'carrierwave-truevault'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carrierwave-truevault

## Usage

You'll need to add a configuration block in your ```
config/initializers/carrierwave.rb ``` file.

```ruby
CarrierWave.configure do |config|
  config.truevault_api_key = "xxxxxx......"
  config.truevault_vault_id = "xxxxx......"
  config.truevault_attributes = {}
end
```

In your uploader add truevault as the storage option:

```ruby
class DocumentUploader < CarrierWave::Uploader::Base
  storage :truevault
end
```

## Contributing

1. Fork it ( https://github.com/codemancode/carrierwave-truevault/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
