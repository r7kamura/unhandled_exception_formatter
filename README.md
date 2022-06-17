# UnhandledExceptionFormatter

Custom RSpec formatter to output unhandled exception.

## Background

To rescue exceptions raised from application,
we often tend to write code like:

```ruby
class ApplicationController < ActionController::Base
  rescue_from ::Exception, :return_internal_server_error
end
```

While this is convenient, it also masks the actual exceptions.
This makes it difficult to debug when unintended exceptions occur during testing.

To mitigate this problem,
I thought it would be nice to be able to output uncaught exceptions by custom RSpec formatter.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add unhandled_exception_formatter
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install unhandled_exception_formatter
```

## Usage

### Setup

This is an example for Rails application.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ::Exception, :return_internal_server_error

  if ::Rails.env.test?
    rescue_from ::Exception, :store_unhandled_exception

    before_action :clear_unhandled_exception
  end

  private

  def clear_unhandled_exception
    ::UnhandledExceptionRspecFormatter.unhandled_exception = nil
  end

  # @param [Exception] exception
  # @raise [Exception]
  def store_unhandled_exception(exception)
    ::UnhandledExceptionRspecFormatter.unhandled_exception = exception
    raise exception
  end
end
```

### Run

This formatter only outputs information about unhandled exceptions,
so use multiple formatter together to get the output you want.

```
rspec --format documentation --format UnhandledExceptionFormatter
```

Note: RSpec automatically `require 'unhandled_exception_formatter'` from `--format` option,
so there is no need to do this by your side.

### Example output

```
$ rspec --format documentation --format UnhandledExceptionFormatter

UnhandledExceptionFormatter
  example at ./spec/foo_spec.rb:4 (FAILED - 1)
Unhandled exception:
  class:
    RuntimeError
  message:
    example exception
  short backtrace:
    /home/r7kamura/ghq/github.com/r7kamura/unhandled_exception_formatter/spec/foo_spec.rb:5:in `block (2 levels) in <top (required)>'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/example.rb:263:in `instance_exec'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/example.rb:263:in `block in run'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/example.rb:511:in `block in with_around_and_singleton_context_hooks'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/example.rb:468:in `block in with_around_example_hooks'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/hooks.rb:486:in `block in run'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/hooks.rb:624:in `run_around_example_hooks_for'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/hooks.rb:486:in `run'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/example.rb:468:in `with_around_example_hooks'
    /home/r7kamura/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rspec-core-3.11.0/lib/rspec/core/example.rb:511:in `with_around_and_singleton_context_hooks'

Failures:

  1) UnhandledExceptionFormatter
     Failure/Error: fail
     RuntimeError:
     # ./spec/foo_spec.rb:7:in `block (2 levels) in <top (required)>'

Finished in 0.00088 seconds (files took 0.05668 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/foo_spec.rb:4 # UnhandledExceptionFormatter
```

The above output is obtained from this code:

```ruby
# spec/foo_spec.rb
require 'unhandled_exception_formatter'

RSpec.describe UnhandledExceptionFormatter do
  it do
    exception = raise 'example exception' rescue $!
    described_class.unhandled_exception = exception
    fail
  end
end
```
