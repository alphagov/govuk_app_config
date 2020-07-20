require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Lint Ruby"
task :lint do
  sh "bundle exec rubocop --format clang"
end

task default: %i[spec lint]
