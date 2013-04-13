# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'activerecord-denormalize/version'

Gem::Specification.new do |gem|
  gem.name          = 'activerecord-denormalize'
  gem.version       = ActiveRecord::Denormalize::VERSION
  gem.authors       = ['Keita Urashima']
  gem.email         = ['ursm@ursm.jp']
  gem.description   = %q{Denormalize fields in ActiveRecord.}
  gem.summary       = %q{}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'activerecord'
  gem.add_dependency 'activerecord-postgres-hstore'

  gem.add_development_dependency 'appraisal'
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'rspec'
end
