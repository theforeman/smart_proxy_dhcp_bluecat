require "rake"
require "rake/testtask"
require "rubocop/rake_task"

RuboCop::RakeTask.new

# rufo must be the last: https://github.com/ruby-formatter/rufo/pull/262/files
task all: [:test, :rubocop, "rufo:check"]
task default: :all

Rake::TestTask.new(:test) do |t|
  t.libs << "."
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.6.0")
  task rufo: ["rufo:run"]
  namespace :rufo do
    require "rufo"

    def rufo_command(*switches, rake_args)
      files_or_dirs = rake_args[:files_or_dirs] || "."
      args = switches + files_or_dirs.split
      Rufo::Command.run(args)
    end

    desc "Format Ruby code in current directory"
    task :run, [:files_or_dirs] do |_task, rake_args|
      rufo_command(rake_args)
    end

    desc "Check that no formatting changes are produced"
    task :check, [:files_or_dirs] do |_task, rake_args|
      rufo_command("--check", rake_args)
    end
  end
end
