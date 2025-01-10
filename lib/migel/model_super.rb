#!/usr/bin/env ruby
# frozen_string_literal: true

# Migel::Model::SuperModel -- migel -- 02.10.2012 -- yasaka@ywesee.com
# Migel::Model::SuperModel -- migel -- 24.01.2012 -- mhatakeyama@ywesee.com
require 'active_support/inflector' # for singularize

module Migel
  # forward definitions (circular dependency Model <-> M10lDocument)
  class ModelSuper; end

  module Util; class M10lDocument < ModelSuper; end; end

  class ModelSuper
    class Predicate
      attr_reader :action, :type, :delegators

      def initialize(action, type, *delegators)
        raise "unknown predicate type: #{type}" unless respond_to?(type)

        @action = action
        @type = type
        @delegators = delegators
      end

      def cascade(action, next_level)
        if next_level.is_a?(Array)
          if action == :delete
            while (element = next_level.shift)
              cascade(action, element)
            end
          else
            next_level.each do |element|
              cascade(action, element)
            end
          end
        elsif next_level.respond_to?(action)
          next_level.send(action)
        end
      end

      def delegate(action, next_level); end

      def execute(action, object)
        return unless action == @action

        @delegators.each do |delegator|
          send(@type, action, object.send(delegator))
        end
      end
    end
    class << self
      def belongs_to(groupname, *predicates)
        attr_reader groupname

        varname = "@#{groupname}"
        connections.push(varname)
        selfname = singular
        define_method(:"#{groupname}=") do |group|
          old = instance_variable_get(varname)
          if old != group
            if old
              old.send(:"remove_#{selfname}", self)
              old.save
            end
            if group
              group.send(:"add_#{selfname}", self)
              group.save
            end
          end
          instance_variable_set(varname, group)
        end
        predicates.each do |predicate|
          if predicate.action == :method_missing
            predicate.delegators.each do |key|
              define_method(key) do
                if (group = instance_variable_get(varname))
                  group.send(key)
                end
              end
            end
          else
            predicate.delegators.push(groupname)
            self.predicates.push(predicate)
          end
        end
      end

      def connections
        @connections ||= []
      end

      def connector(key)
        connectors.push "@#{key}"
      end

      def connectors
        @connectors ||= []
      end

      def delegates(*delegators)
        Predicate.new(:method_missing, :delegate, *delegators)
      end

      def has_many(plural, *predicates)
        varname = "@#{plural}"
        define_method(plural) do
          instance_variable_get(varname) or begin
            instance_variable_set(varname, [])
          end
        end
        define_method(:"add_#{plural.to_s.singularize}") do |inst|
          container = send(plural)
          container.push(inst) unless container.any? { |other| inst.eql? other }
          inst
        end
        define_method(:"remove_#{plural.to_s.singularize}") do |inst|
          send(plural).delete_if { |other| inst.eql? other }
        end
        connectors.push(varname)
        predicates.each do |predicate|
          if predicate.type == :delegate
            predicate.delegators.each do |key|
              define_method(key) do
                send(plural).collect do |inst|
                  inst.send(key)
                end.flatten
              end
            end
          else
            predicate.delegators.push(plural)
            self.predicates.push(predicate)
          end
        end
      end

      def on_delete(action, *delegators)
        Predicate.new(:delete, action, *delegators)
      end

      def on_save(action, *delegators)
        Predicate.new(:save, action, *delegators)
      end

      def predicates
        @predicates ||= []
      end

      def is_coded
        has_many :codes
        define_method(:code) do |*args|
          type, country = *args
          codes.find { |code| code.is_for?(type, country || 'DE') }
        end
      end

      def m10l_document(key)
        varname = "@#{key}"
        define_method(key) do
          instance_variable_get(varname) or begin
            instance_variable_set(varname, Util::M10lDocument.new)
          end
        end
        connectors.push varname
      end

      def multilingual(key)
        define_method(key) do
          instance_variable_get(:"@#{key}") or begin
            instance_variable_set(:"@#{key}", Util::Multilingual.new)
          end
        end
        define_method(:to_s) do
          send(key).to_s
        end
      end

      def singular
        if respond_to?(:basename)
          basename.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
        else
          to_s.split('::').last.downcase.to_s.singularize
        end
      end

      def serialize(key); end
    end
    def data_origin(key)
      # print "data_origins.class = "
      # p data_origins.class
      data_origins[key]
    end

    def data_origins
      @data_origins ||= {}
    end

    def delete
      item = dup
      item.class.predicates.each do |predicate|
        predicate.execute(:delete, self)
      end
      item
    end

    def save
      item = dup
      item.class.predicates.each do |predicate|
        predicate.execute(:save, self)
      end
      item
    end

    def update_limitation_text(str, language)
      limitation_text(true).send("#{language}=", str)
      @limitation_text.parent = self
    end

    def pointer
      'pointer'
    end

    def method_missing(meth, *args, &block)
      if /^[a-z]{2}$/.match?(meth.to_s)
        name.de
      else
        super
      end
    end
  end
end

require 'migel/util/m10l_document'
