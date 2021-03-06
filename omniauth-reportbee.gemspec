# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-reportbee/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-reportbee'
  spec.version       = Omniauth::Reportbee::VERSION
  spec.authors       = ['Report Bee']
  spec.email         = ['admin@reportbee.com']

  spec.summary       = %q{Report Bee omniauth gem }
  spec.description   = %q{Implements omniauth functionality for clients of Report Bee applications}
  spec.homepage      = 'https://www.reportbee.com/'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://reportbee.codebasehq.com/projects/reportbee/repositories/omniauth-reportbee'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_dependency 'omniauth-oauth2', ['~> 1.5.0']
  spec.add_dependency 'json'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'airbrake', '~> 5.4'
end
