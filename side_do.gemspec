# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','side_do','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'side_do'
  s.version = SideDo::VERSION
  s.author = 'Wang Guangxing'
  s.email = '734569969@qq.com'
  s.homepage = 'https://github.com/veetase/side_do'
  s.platform = Gem::Platform::RUBY
  s.summary = "side_do  is a simple command-line tool for making game seeds, uploading game seeds to remote servers and so on.  It does so safely and quietly, it's perfect for use with cron as a cron work."
  s.files = `git ls-files`.split("")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','side_do.rdoc']
  s.rdoc_options << '--title' << 'side_do' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'side_do'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.9.0')
  s.add_dependency('activerecord')
  s.add_dependency('mysql2')
end
