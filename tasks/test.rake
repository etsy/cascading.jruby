require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:run) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/**/test_*.rb']
    t.ruby_opts += ['-w']
  end
end

desc 'test:run with dependencies resolved'
task :test => ['ant:retrieve', 'test:run']
