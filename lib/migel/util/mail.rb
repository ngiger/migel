#!/usr/bin/env ruby

# Migel::Util::Mail -- migel -- 10.01.2012 -- mhatakeyama@ywesee.com

require "net/smtp"
require "migel/config"
require "mail"
require "base64"

module Migel
  module Util
    module Mail
      def self.notify_admins_attached(subj, lines, file)
        @@configured ||= false
        config = Migel.config
        config.admins << Etc.getlogin if config.admins.size == 0
        config.mail_from ||= Etc.getlogin
        unless ::Mail.delivery_method.is_a?(::Mail::TestMailer) and !@@configured
          ::Mail.defaults do
            delivery_method :smtp, {
              address: config.smtp_server,
              port: config.smtp_port,
              domain: config.smtp_domain,
              user_name: config.smtp_user,
              password: config.smtp_pass,
              authentication: config.smtp_authtype
            }
          end
          @@configured = true
        end
        ::Mail.deliver do
          subject subj
          from config.mail_from
          to config.admins
          body lines.join("\n")
          if file
            add_file filename: File.basename(file), content: File.read(file)
          end
        end
      end
    end
  end
end
