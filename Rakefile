require 'bundler/setup'
require "bundler/gem_tasks"
Bundler.require(:development)
require 'rake/testtask'
require 'rdoc/task'

task :console do
  exec 'irb -I lib -r mls.rb'
end
task :c => :console

Rake::TestTask.new do |t|
    t.libs << 'lib' << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    #t.warning = true
    #t.verbose = true
end

Rake::RDocTask.new do |rd|
  rd.main = 'README.rdoc'
  rd.title = 'MLS Documentation'
  rd.rdoc_dir = 'doc'
  
  rd.options << '-f' << 'sdoc' # explictly set shtml generator
  rd.options << '-T' << '42floors'
  rd.options << '-g' # Generate github links
  
  rd.rdoc_files.include('README.rdoc')
  rd.rdoc_files.include('lib/**/*.rb')
end

desc "Run tests"
task :default => :test

namespace :pages do
  #TODO: https://github.com/defunkt/sdoc-helpers/blob/master/lib/sdoc_helpers/pages.rb
end