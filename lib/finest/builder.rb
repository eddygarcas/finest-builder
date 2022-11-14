# frozen_string_literal: true

require 'finest/builder/version'

# Add snake case in String
class String
  def snake_case
    length > 7 ? strip.gsub(/(\w[A-Z]|\s\S)/) { |e| "#{e[0].strip}_#{e[1].strip.downcase}" }.downcase : strip.downcase
  end
end

module Finest
  # Finest Builder
  module Helper

    # Parses a given json structure looking for specific keys inside the structure if passed
    #
    # The result it's stored on a instance variable called to_h and accessible through accessor with same name
    # as well as it created a instance method for every key.
    # All methods are created using the snake case approach.
    #
    #   e = MyObjectBuilder.new({"client"=> {"idSA"=>1,"id"=>3434, "ManagementType"=>"iOSUnsupervised"}})
    #
    # Result:
    #   e.client.to_h[:id_sa]
    #   e.client.id_sa
    #
    # Any key value less than three characters will just be down cased.
    #   e.client.to_h[:id]
    #   e.client.id
    #
    def build_by_keys(json = {}, keys = [])

      keys = keys.empty? ? json.keys : keys
      raise ArgumentError unless keys&.respond_to?(:each)

      json.transform_keys!(&:to_s)
      keys&.reject! { |key| key.end_with?('=') }
      keys&.each do |key|
        send("#{key.to_s.snake_case}=", nested_hash_value(json, key.to_s))
      end
      yield self if block_given?
      self
    end

    # Builds an instance variable as well as its class method accessors from a key value pair.
    def accessor_builder(key, val)
      instance_variable_set("@#{key}", val)
      self.class.send(:define_method, key.to_s, proc { instance_variable_get("@#{key}") })
      self.class.send(:define_method, "#{key}=", proc { |val| instance_variable_set("@#{key}", val) })
    end

    # Goes through a complex Hash nest and gets the value of a passed key.
    # First wil check whether the object has the key? method,
    # which will mean it's a Hash and also if the Hash the method parameter key
    #   if obj.respond_to?(:key?) && obj.key?(key)
    #
    # If result object is a hash itself, will call constructor method to parse this hash first.
    #
    #  if obj[key].is_a?(Hash)
    #           self.class.new(obj[key])
    #
    # If it's an array, will call the constructor method for each element of the array, mapping the result.
    #
    #  elsif (obj[key].is_a?(Array))
    #
    # As mentioned before, this methods looks for the key passed as parameter, if it's not found, will
    # go through the nested hash looking for the key, calling itself recursively.
    #
    # This way we can look for specific keys inside a complex hash structure and ignore the rest.
    # The result of this action will be an object with the keys found and their values.
    # If eventually the keys was not found, it will assign nil to the instance variable.
    #
    def nested_hash_value(obj, key)
      if obj.respond_to?(:key?) && obj.key?(key)
        if obj[key].is_a?(Hash)
          self.class.new(obj[key])
        elsif (obj[key].is_a?(Array))
          obj[key].map! do |a|
            a.respond_to?(:key?) ? self.class.new(a) : a
          end
        else
          obj[key]
        end
      elsif obj.respond_to?(:each)
        r = nil
        obj.find do |*a|
          r = nested_hash_value(a.last, key)
        end
        r
      end
    end

    def method_missing(name, *args)
      accessor_builder(name.to_s.gsub(/=$/, ''), args[0]) if name.to_s =~ /=$/
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with?('to_') || super
    end

    def attribute_from_inner_key(elem, attr, in_key = nil)
      { attr.to_sym => nested_hash_value(elem, in_key&.present? ? in_key : attr.to_s) }
    end

  end

  # Finest Struct
  module Struct
    class Error < StandardError; end

    include Helper

    def initialize(json = {}, keys = [])
      accessor_builder('to_h', {})
      json.each do |k, v|
        send("#{k}=", v)
      end
    end

    def method_missing(name, *args)
      attribute = name.to_s.start_with?(/\d/) ? "_#{name.to_s}" : name.to_s
      if attribute =~ /=$/
        @to_h[attribute.chop] =
          if args[0].respond_to?(:key?) || args[0].is_a?(Hash)
            self.class.new(json: args[0])
          else
            args[0]
          end
      else
        @to_h[attribute]
      end
    end

    def respond_to_missing?; end

  end

  # Finest Builder
  module Builder
    include Helper

    class Error < StandardError; end

    alias initialize build_by_keys

  end

end
