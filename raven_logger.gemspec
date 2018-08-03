Gem::Specification.new do |gem|
  gem.name        = 'raven_logger'
  gem.version     = '0.0.1'
  gem.date        = '2018-08-02'
  gem.summary     = "Ruby Raven Logger"
  gem.description = "Send arbritary events to Sentry"
  gem.authors     = ["Giv Parvaneh"]
  gem.email       = 'giv@givp.org'
  gem.files       = ["lib/raven_logger.rb"]
  gem.homepage    = 'http://rubygems.org/gems/raven_logger'
  gem.license     = 'MIT'

  gem.add_dependency 'rest-client', '1.6.7'
  gem.add_dependency 'git-revision', '0.0.1'
end