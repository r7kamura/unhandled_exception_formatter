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
rspec --format doc --format UnhandledExceptionFormatter
```

Note: RSpec automatically `require 'unhandled_exception_formatter'` from `--format` option,
so there is no need to do this by your side.
