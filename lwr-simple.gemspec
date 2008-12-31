Gem::Specification.new do |s|
  s.name = %q{lwr-simple}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["yagita"]
  s.cert_chain = ["/home/yagita/.gem/gem-public_cert.pem"]
  s.date = %q{2009-01-01}
  s.description = %q{nodoc...}
  s.email = ["yagihiro@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "lib/lwr-simple.rb", "lwr-simple.gemspec", "script/console", "script/destroy", "script/generate", "spec/lwr-simple_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{This library is the powerful web access library like LWP::Simple module.}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{lwr-simple}
  s.rubygems_version = %q{1.2.0}
  s.signing_key = %q{/home/yagita/.gem/gem-private_key.pem}
  s.summary = %q{nodoc...}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<newgem>, [">= 1.2.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.2.1"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.2.1"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
