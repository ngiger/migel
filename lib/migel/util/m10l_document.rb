#!/usr/bin/env ruby
# frozen_string_literal: true

# Migel::Util::M10lDocument -- migel -- 17.08.2011 -- mhatakeyama@ywesee.com

require "English"
require "migel/model_super"
require "migel/util/multilingual"

module Migel
  module Util
    class M10lDocument < ModelSuper
      include M10lMethods
      connector :canonical
      attr_reader :previous_sources

      def initialize(canonical = {})
        super
        @previous_sources = {}
      end

      def add_previous_source(lang, source)
        sources = (@previous_sources[lang.to_sym] ||= [])
        sources.push source
        sources.compact!
        sources.uniq!
        sources
      end

      def empty?
        @canonical.empty?
      end

      def respond_to_missing?
        true
      end

      def method_missing(meth, *args, &block)
        case meth.to_s
        when /^([a-z]{2})=$/
          lang = $LAST_MATCH_INFO[1].to_sym
          if (previous = @canonical[lang])
            add_previous_source(lang, previous.source)
          end
          @canonical.store(lang, args.first)
        else
          super
        end
      end
    end
  end
end
