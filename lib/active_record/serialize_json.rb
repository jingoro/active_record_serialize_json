require 'active_record/base'
require 'json'

module ActiveRecord
  class SerializeJSON
    def initialize(attribute, opts = {})
      @attribute = attribute.to_s.to_sym
      @serialize = opts[:serialize] || {}
      @deserialize = opts[:deserialize] || {}
    end

    attr_reader :attribute

    def before_save(record)
      json = serialize record
      record.__send__(:"#{@attribute}=", json)
    end

    def after_save(record)
      data = deserialize record
      record.__send__(:"#{@attribute}=", data)
    end

    def serialize(record)
      self.class.serialize(record.__send__(@attribute), @serialize)
    end

    def deserialize(record)
      self.class.deserialize(record.__send__(@attribute), @deserialize)
    end

    def self.serialize(value, opts = {})
      opts ||= {}
      JSON.generate(value, opts)
    end

    def self.deserialize(value, opts = {})
      opts ||= {}
      JSON.parse(value, opts)
    rescue => e
      Rails.logger.warn e
      value
    end
  end

  class Base
    def self.serialize_json(attribute, opts = {})
      sj = SerializeJSON.new(attribute, opts)

      before_save sj
      after_save  sj

      unless respond_to?(:serialize_json_attributes)
        cattr_accessor :serialize_json_attributes
        self.serialize_json_attributes = {}
      end
      serialize_json_attributes[sj.attribute] = sj

      class_eval do
        define_method(:after_find) do
          super if defined? super
          self.class.serialize_json_attributes.each do |attribute, sj|
            __send__(:"#{attribute}=", sj.deserialize(self))
          end
        end
      end
    end
  end
end
