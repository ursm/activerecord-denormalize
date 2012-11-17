# ActiveRecord::Denormalize

Denormalize fields in ActiveRecord.

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-denormalize'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-denormalize

## Usage

``` ruby
class Message < ActiveRecord::Base
  belongs_to :sender, polymorphic: true
end

class User < ActiveRecord::Base
  # name:string

  has_many :messages, as: :sender, denormalize: {
    attributes: [:name]
  }
end

class Bot < ActiveRecord::Base
  # name:string

  has_many :messages, as: :sender, denormalize: {
    attributes: [:name]
  }
end

user    = User.create!(name: 'foo')
message = Message.create!(sender: user)

message.sender_name #=> 'foo'

user.update_attribute 'name', 'bar'

message.reload
message.sender_name #=> 'bar'

Message.all.each do |msg|
  # no N+1 query
  msg.sender_name
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
