# frozen_string_literal: true

require_relative "lib/claude/ruby/version"

Gem::Specification.new do |spec|
  spec.name = "claude-ruby"
  spec.version = Claude::Ruby::VERSION
  spec.authors = ["Web Ventures Ltd"]
  spec.email = ["webven@mailgab.com"]

  spec.summary     = 'A Ruby SDK for the Anthropic Claude API'
  spec.description = 'Unofficial ruby SDK for interacting with the Anthropic API, for generating and streaming messages through Claude.'
  spec.homepage = "https://github.com/webventures/claude-ruby.git"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/webventures/claude-ruby.git"
  spec.metadata["changelog_uri"] = "https://github.com/webventures/claude-ruby/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rest-client'
end
