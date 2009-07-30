# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hcl}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zack Hobson"]
  s.date = %q{2009-07-30}
  s.default_executable = %q{hcl}
  s.description = %q{HCl is a command-line client for manipulating Harvest time sheets.}
  s.email = %q{zack@opensourcery.com}
  s.executables = ["hcl"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".gitignore",
     ".gitmodules",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION.yml",
     "bin/hcl",
     "hcl.gemspec",
     "hcl_conf.yml.example",
     "lib/hcl.rb",
     "lib/hcl/day_entry.rb",
     "lib/hcl/project.rb",
     "lib/hcl/task.rb",
     "lib/hcl/timesheet_resource.rb",
     "lib/hcl/utility.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/zenhob/hcl}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Harvest timesheets from the command-line}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<termios>, [">= 0"])
      s.add_runtime_dependency(%q<trollop>, [">= 1.10.2"])
      s.add_runtime_dependency(%q<chronic>, [">= 0.2.3"])
      s.add_runtime_dependency(%q<highline>, [">= 1.5.1"])
    else
      s.add_dependency(%q<termios>, [">= 0"])
      s.add_dependency(%q<trollop>, [">= 1.10.2"])
      s.add_dependency(%q<chronic>, [">= 0.2.3"])
      s.add_dependency(%q<highline>, [">= 1.5.1"])
    end
  else
    s.add_dependency(%q<termios>, [">= 0"])
    s.add_dependency(%q<trollop>, [">= 1.10.2"])
    s.add_dependency(%q<chronic>, [">= 0.2.3"])
    s.add_dependency(%q<highline>, [">= 1.5.1"])
  end
end
