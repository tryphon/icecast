# Icecast Ruby client

Ruby client to access to Icecast XML API

## Installation

Add this line to your application's Gemfile:

    gem 'icecast'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install icecast

## Usage

    master = Icecast::Server.new :host => "stream.example.com, :admin_password => "secret"
    
    master.status.stream("mystream.mp3").listeners # => 47
    master.status.stream("dummy.mp3").started? # => false
    
    slave = Icecast::Server.new :host => "stream2.example.com", :port => 80, :admin_password => "othersecret"
    cluster = Icecast::Cluster.new(master, slave)
    
    cluster.status.stream("mystream.mp3").listeners

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
