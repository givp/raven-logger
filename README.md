# Raven-Logger, a Ruby Client for sending arbitrary events to Sentry

This is a simple wrapper for a poorly-documented feature in Sentry. This gem will allow you to log events to your Sentry project. This will also submit recent git info on your current branch.

### Install

```ruby
gem "raven-logger"
```

### Usage

- You need your Sentry project URL which looks like this: `https://sentry.io/api/<your_project_id>/store/` as well as your key and secret.

```ruby
require 'raven_logger'

logger = RavenLogger.new(SENTRY_URL, SENTRY_KEY, SENTRY_SECRET)

logger.captureMessage("Something happened", extra: { user_ids: 123 }, level: :info)

```