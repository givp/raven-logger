require 'securerandom'
require 'digest'
require 'socket'
require 'time'
require 'rest-client'
require 'json'
require 'git-revision'

class RavenLogger

  class << self
    def captureMessage(title, opts={})
      new.captureMessage(title, opts)
    end
  end

  def captureMessage(title, opts={})
    raise ArgumentError.new('Event title is missing') if !title
    raise ArgumentError.new('SENTRY_PROJECT_URL env variable is missing') if !ENV['SENTRY_PROJECT_URL']
    raise ArgumentError.new('SENTRY_KEY env variable is missing') if !ENV['SENTRY_KEY']
    raise ArgumentError.new('SENTRY_SECRET env variable is missing') if !ENV['SENTRY_SECRET']

    opts = symbolize_keys(opts)
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
      "environment": ENV['RAILS_ENV'] || 'testing',
      "level": level,
      "extra": extra
    }

    RestClient.post ENV['SENTRY_PROJECT_URL'], payload.to_json, headers
    Rails.logger.debug("Sentry event sent.".green)
    nil
  end

  private

  def headers
    headers = {
      "Content-Type": "application/json",
      "X-Sentry-Auth": "Sentry sentry_version=7, sentry_timestamp=#{Time.now.utc.to_i}, sentry_key=#{ENV['SENTRY_KEY']}, sentry_secret=#{ENV['SENTRY_SECRET']}, sentry_client=raven-intricately/1.0"
    }
  end

  def symbolize_keys(obj)
    case obj
    when Array
      obj.inject([]){|res, val|
        res << case val
        when Hash, Array
          symbolize_keys(val)
        else
          val
        end
        res
      }
    when Hash
      obj.inject({}){|res, (key, val)|
        nkey = case key
        when String
          key.to_sym
        else
          key
        end
        nval = case val
        when Hash, Array
          symbolize_keys(val)
        else
          val
        end
        res[nkey] = nval
        res
      }
    else
      obj
    end
  end

end