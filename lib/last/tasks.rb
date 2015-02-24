require "last/tasks/version"

unless Rake::Task.task_defined?(:application) && Rake::Task.task_defined?(:environment)
  puts "Last::Tasks requires \"application\" and \"environment\" tasks to be defined."
  exit 1
end

load "last/tasks/db.rake"
load "last/tasks/test.rake"
