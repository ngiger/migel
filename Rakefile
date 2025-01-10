#!/usr/bin/env ruby

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "migel/version"
require "rspec/core/rake_task"
require "standard/rake"

RSpec::Core::RakeTask.new(:spec)

task spec: :clean

require "rake/clean"
CLEAN.include FileList["pkg/*.gem"]
