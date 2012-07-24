require "bundler/gem_tasks"
require 'rake/testtask'

task :console do
  exec 'irb -I lib -r mls.rb'
end
task :c => :console


Rake::TestTask.new do |t|
    t.libs << 'lib' << 'test'
    t.test_files = FileList['test/units/**/test*.rb']
    t.warning = true
    t.verbose = true
end

desc "Run tests"
task :default => :test
