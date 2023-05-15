# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"
require "rubocop/rake_task"

CLEAN.add("coverage")
CLEAN.add(".rspec_status")
CLOBBER.add("*.zip")

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]
