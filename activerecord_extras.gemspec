require_relative 'lib/active_record/extras/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord_extras"
  spec.version       = ActiveRecord::Extras::VERSION
  spec.authors       = ["Till Schulte-Coerne"]
  spec.email         = ["ruby@trsnet.de"]

  spec.summary       = "Extensions and utilities for ActiveRecord, including association subqueries and convenience scopes."
  spec.description   = "activerecord_extras provides utility methods and scopes for ActiveRecord models, including EXISTS and COUNT subqueries on has_many associations, and SQL helpers for boolean casting."
  spec.homepage      = "https://github.com/tillsc/activerecord_extras"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7"

  spec.files = Dir["lib/**/*.rb"] + ["README.md", "LICENSE.md"]
  spec.require_paths = ["lib"]

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage
  }

  spec.add_dependency "activerecord", "~> 8.0"
  spec.add_dependency "activesupport", "~> 8.0"
end