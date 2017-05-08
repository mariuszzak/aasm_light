# AasmLight

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/aasm_light`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aasm_light'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aasm_light

## Usage

Adding a state machine is as simple as including the AasmLight module and start defining
**states** and **events** together with their **transitions**:

```ruby
class Job
  include AasmLight

  aasm do
    state :sleeping, :initial => true
    state :running, :cleaning

    event :run do
      transitions :from => :sleeping, :to => :running
    end

    event :clean do
      transitions :from => :running, :to => :cleaning
    end

    event :sleep do
      transitions :from => [:running, :cleaning], :to => :sleeping
    end
  end

end
```

This provides you with a couple of public methods for instances of the class `Job`:

```ruby
job = Job.new
job.sleeping? # => true
job.may_run?  # => true
job.run
job.running?  # => true
job.sleeping? # => false
job.may_run?  # => false
job.run       # => raises AASM::InvalidTransition
```

If you don't like exceptions and prefer a simple `true` or `false` as response, tell
AASM not to be *whiny*:

```ruby
class Job
  ...
  aasm :whiny_transitions => false do
    ...
  end
end

job.running?  # => true
job.may_run?  # => false
job.run       # => false
```

When firing an event, you can pass a block to the method, it will be called only if
the transition succeeds :

```ruby
  job.run do
    job.user.notify_job_ran # Will be called if job.may_run? is true
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Mariusz Zak/aasm_light.

