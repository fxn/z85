require "rake/testtask"
require "rake/extensiontask"

Rake::ExtensionTask.new("z85") do |ext|
  ext.lib_dir = "lib/z85"
end

Rake::TestTask.new do |t|
  t.test_files = Dir.glob("test/lib/**/test_*.rb")
  t.libs << "test"
end

task :test => :compile
task :default => :test
