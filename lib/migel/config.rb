#!/usr/bin/env ruby
# frozen_string_literal: true

# Migel@config -- migel -- 19.09.2011 -- mhatakeyama@ywesee.com

require 'rclconf'
require 'migel'

module Migel
  default_dir = File.expand_path('../../etc', File.dirname(__FILE__))
  default_config_files = [
    File.join(default_dir, 'migel.yml'), '/etc/migel/migel.yml'
  ]
  defaults = {
    'config'	=> default_config_files,
    'db_name' => 'migel',
    'db_user' => 'migel',
    'db_auth' => 'migel',
    'persistence' => 'odba',
    'server_name' => 'migel',
    'server_url' => 'druby://127.0.0.1:33000',
    'migel_dir' => default_dir,
    'log_file' => $stderr,
    'log_level' => 'INFO',

    'admins' => [],
    'mail_from' => 'update@ywesee.com',
    'mail_charset' => 'utf8',
    'smtp_authtype' => :plain,
    'smtp_domain' => 'ywesee.com',
    'smtp_pass' => nil,
    'smtp_port' => 587,
    'smtp_server' => 'localhost',
    'smtp_user' => 'update@ywesee.com'
  }
  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
  require 'migel/util/logger'
  logger.info "server_url set to: #{config.server_url}"
end
