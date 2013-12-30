# encoding: UTF-8

Gem::Specification.new do |s|

  s.platform              = Gem::Platform::RUBY
  s.name                  = 'spree_vend'
  s.version               = '0.1.0'
  s.summary               = 'Integrates Spree with Vend POS'
  s.required_ruby_version = '>= 1.8.7'

  s.author                = 'Robbie Pitts'
  s.email                 = 'self@rpitts.me'
  s.homepage              = 'http://www.rpitts.me'

  s.files                 = `git ls-files`.split("\n")
  s.require_path          = 'lib'
  s.requirements         << 'none'

  s.add_dependency 'spree', '~> 0.70.0'
  s.add_dependency 'spree_promo', '~> 0.70.0'
  s.add_dependency 'curb'
  s.add_dependency 'hashie'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'fabrication'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'database_cleaner'
  
end
