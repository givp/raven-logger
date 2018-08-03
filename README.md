# Raven-Logger, a Ruby Client for sending arbitrary events to Sentry

This is a simple wrapper for a poorly-documented feature in Sentry. This gem will allow you to log events to your Sentry project. This will also submit recent git info on your current branch.

### Install

```ruby
gem install raven_logger
```

### Setup

You need the following environment variables set:

- `SENTRY_PROJECT_URL` - Your Sentry project URL which looks like this: `https://sentry.io/api/<your_project_id>/store/`.
- `SENTRY_KEY`
- `SENTRY_SECRET`

### Usage

```ruby
require 'raven_logger'

RavenLogger.captureMessage("Something happened", extra: { user_ids: 123 }, level: :info)

```