require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

namespace :docker do
  task :test do
    system("docker build -t andrewbruce/pongruby .") &&
      system("docker run andrewbruce/pongruby")
  end
end

task default: :test
