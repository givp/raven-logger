require 'securerandom'
require 'digest'
require 'socket'

class RavenLogger

  attr_reader :sentry_url, :sentry_key, :sentry_secret
  def initialize(sentry_url, sentry_key, sentry_secret)
    @sentry_url = sentry_url
    @sentry_key = sentry_key
    @sentry_secret = sentry_secret
  end

  def captureMessage(title, opts={})
    raise ArgumentError.new('Event title is missing') if !title

    opts.symbolize_keys!
    opts[:level] ||= :info
    extra = opts[:extra] || {}
    level = opts[:level].to_s

    valid_levels = %w(fatal error warning info debug)

    if !valid_levels.include? level
      raise ArgumentError.new("'#{level}' is not a valid level. Please use either: #{valid_levels.join(", ")}")
    end

    extra.merge!(git_message: Git::Revision.message)

    payload = {
      "event_id": (Digest::MD5.hexdigest SecureRandom.uuid),
      "timestamp": Time.now.utc.iso8601,
      "message": title,
      "logger": "ruby",
      "release": Git::Revision.commit_short,
      "server_name": Socket.gethostname,
      "environment": ENV['RAILS_ENV'] || 'production',
      "level": level,
      "extra": extra
    }

    RestClient.post sentry_url, payload.to_json, headers
    Rails.logger.debug("Sentry event sent.".green)
    nil
  end

  private

  def headers
    headers = {
      "Content-Type": "application/json",
      "X-Sentry-Auth": "Sentry sentry_version=7, sentry_timestamp=#{Time.now.utc.to_i}, sentry_key=#{sentry_key}, sentry_secret=#{sentry_secret}, sentry_client=raven-intricately/1.0"
    }
  end

end