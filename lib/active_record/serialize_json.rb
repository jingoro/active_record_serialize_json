require 'active_record'
require 'active_support/json'

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
      self.class.serialize(record, record.__send__(@attribute), @serialize)
    end

    def deserialize(record)
      self.class.deserialize(record, record.__send__(@attribute), @deserialize)
    end

    def self.serialize(record, value, opts = {})
      opts ||= {}
      value.to_json(opts)
    end

    def self.deserialize(record, value, opts = {})
      opts ||= {}
      # ActiveSupport::JSON does not take options
      ActiveSupport::JSON.decode(value)
    rescue => e
      record.logger && record.logger.warn(e)
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
        if ActiveRecord::VERSION::MAJOR < 3
          define_method(:after_find) do
            super if defined? super
            serialize_json_attribute_after_find
          end
        else
          after_find :serialize_json_attribute_after_find
        end
        define_method(:serialize_json_attribute_after_find) do
          self.class.serialize_json_attributes.each do |attribute, sj|
            __send__(:"#{attribute}=", sj.deserialize(self))
          end
        end
      end
    end
  end
end
