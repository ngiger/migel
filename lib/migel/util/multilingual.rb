#!/usr/bin/env ruby
# frozen_string_literal: true

# Migel::Util::Multilingual -- migel -- 26.08.2011 -- mhatakeyama@ywesee.com

require 'English'
module Migel
  module Util
    module M10lMethods
      include Comparable
      attr_reader :canonical
      attr_reader :synonyms

      def initialize(canonical = {})
        @canonical = canonical
      end

      def all
        @canonical.values
      end

      def empty?
        @canonical.empty?
      end

      def method_missing(meth, *args, &block)
        case meth.to_s
        when /^[a-z]{2}$/
          @canonical[meth]
        when /^([a-z]{2})=$/
          @canonical.store($LAST_MATCH_INFO[1].to_sym, args.first)
        else
          super
        end
      end

      def to_s
        @canonical.values.compact.min.to_s
      end

      def ==(other)
        case other
        when String
          @canonical.values.any? { |val| val == other } \
            || @synonyms.any? { |val| val == other }
        when M10lDocument
          @canonical == other.canonical && @synonyms == other.synonyms
        when M10lMethods
          @canonical == other.canonical
        else
          false
        end
      end

      def <=>(other)
        all.sort <=> other.all.sort
      end
    end

    class Multilingual
      # include DRb::DRbUndumped
      include M10lMethods
      def initialize(canonical = {})
        super
        @synonyms = []
      end

      def add_synonym(synonym)
        @synonyms.push(synonym).uniq! && synonym
      end

      def all
        terms = super.concat(@synonyms).compact
        terms.concat(terms.collect { |term| term.gsub(/[^\w]/, '') })
        terms.uniq
      end

      def merge(other)
        @synonyms.concat(other.all).uniq!
      end

      attr_writer :parent

      def parent(_arg = nil)
        # This is used when limitation_text is shown in ODDB::View::LimitationText
        @parent
      end

      def pointer
        'pointer'
      end

      def de
        @canonical[:de]
      end
      alias en de
      def fr
        @canonical[:fr]
      end

      # For PointerSteps (snapback links)
      def pointer_descr
        'Limitation'
      end

      def structural_ancestors(_app)
        # [@parent.subgroup.group, @parent.subgroup, @parent]
        ancestors = []
        me = self
        while (parent = me.parent)
          ancestors.unshift parent
          me = parent
        end
        ancestors
      end

      def force_encoding(code)
        @canonical.each_value do |c|
          c.force_encoding(code) if c.is_a?(String)
        end
        @synonyms.each do |s|
          s.force_encoding(code) if s.is_a?(String)
        end
      end
    end
  end
end

require 'migel/util/m10l_document'
