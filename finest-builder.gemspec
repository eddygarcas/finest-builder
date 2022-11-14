# frozen_string_literal: true

require_relative 'lib/finest/builder/version'

Gem::Specification.new do |spec|
  spec.name          = 'finest-builder'
  spec.version       = Finest::Builder::VERSION
  spec.authors       = ['Eduard Garcia Castello']
  spec.email         = %w[edugarcas@gmail.com eduard@rzilient.club]

  spec.summary       = %q{Builder modules to create either class ghost methods from a given JSON or a OpenStruct}
  #spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/eddygarcas/finest-builder'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.2')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/eddygarcas/finest-builder'
  spec.metadata['changelog_uri'] = 'https://github.com/eddygarcas/finest-builder'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
