#!/usr/bin/env ruby
# frozen_string_literal: true

# Migel@logger -- migel -- 17.08.2011 -- mhatakeyama@ywesee.com

require 'fileutils'
require 'logger'
require 'migel/config'

module Migel
  DebugMigel = ENV['DEBUG_MIGEL']
  def self.debug_msg(msg)
    return unless DebugMigel

    $stdout.puts("#{Time.now}: #{msg}")
    $stdout.flush
    @config.log_file.puts("#{Time.now}: #{msg}")
    @config.log_file.flush
  end

  log_file = @config.log_file
  if log_file.is_a?(String)
    FileUtils.mkdir_p(File.dirname(log_file))
    log_file = File.open(log_file, 'a')
    log_file.sync = true
  end
  logger = Logger.new(log_file)
  logger.level = Logger.const_get(@config.log_level)
  ## The PayPal Gem depends on ActiveSupport, which foolishly redefines the
  #  Logger.default_formatter. That's why we need to explicitly set
  #  logger.formatter to the standard Formatter here:
  logger.formatter = Logger::Formatter.new
  @logger = logger
end
