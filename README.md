# PanasonicRcs

This gem wraps the panasonic XMLRPC RCS service. Basically can be used
to register a mac address with their service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'panasonic_rcs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install panasonic_rcs

## Usage

```ruby
# Create a connection, and pass it to the RCS service object
rcs= PanasonicRcs::Rcs.new(PanasonicRcs::Connection.new(username: 'username', password: 'password'))

# List all registered phones on this account
rcs.list_phones
# => ["0030A0360ABF", "0030E01604E2"]

rcs.phone('0040F0CC8E43')

# => {"mac"=>"0040F0CC8E43",
      "url"=>"http://server/model/model.cfg",
      "register_date"=>#<DateTime: 2015-10-26T11:58:31+00:00 ((2457322j,43111s,0n),+0s,2299161j)>,
      "access_date"=>#<DateTime: 2015-10-30T13:14:01+00:00 ((2457326j,47641s,0n),+0s,2299161j)>,
      "note"=>"some note",
      "profile"=>"kxutg200bv3",
      "model"=>"KX-UTG200B",
      "version"=>nil}

rcs.register_phone_with_profile('0040F0CC8E43', 'tgp500')

# => true
```

Errors will raise an RcsError exception.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/panasonic_rcs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
