# frozen_string_literal: true

require_relative "lib/nauvisian/version"

Gem::Specification.new do |spec|
  spec.name = "nauvisian"
  spec.version = Nauvisian::VERSION
  spec.authors = ["OZAWA Sakuro"]
  spec.email = ["10973+sakuro@users.noreply.github.com"]

  spec.summary = "A library for managing Factorio MODs"
  spec.description = "Nauvisian is a ruby library for the management of Factorio MODs (download/upload/enable/disable)"
  spec.homepage = "https://github.com/sakuro/nauvisian"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sakuro/nauvisian.git"
  spec.metadata["changelog_uri"] = "https://github.com/sakuro/nauvisian/blob/main/ChangeLog.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-cli", "~> 1.0"
  spec.add_dependency "dry-inflector", "~> 1.0"
  spec.add_dependency "gdbm", "~> 2.1"
  spec.add_dependency "rack", "~> 3.0"
  spec.add_dependency "retriable", "~> 3.1.2"
  spec.add_dependency "ruby-progressbar", "~> 1.11"
  spec.add_dependency "rubyzip", "~> 2.3"
end
