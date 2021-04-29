require "finest/builder/version"

class String
  def snake_case
    length > 7 ? gsub(/(\w[A-Z])/) { |e| "#{e[0]}_#{e[1].downcase}" }.downcase : downcase
  end
end

module Finest
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
    def build_by_keys(json = {}, keys = nil)
      k = keys || json&.keys
      raise ArgumentError "keys argument is not an array" unless k&.respond_to?(:each)
      accessor_builder('to_h', {}) unless self.class.method_defined?(:as_json)
      json.transform_keys!(&:to_s)
      k&.reject! { |ky| ky.end_with?('=') }
      k&.each do |key|
        self.send("#{key.to_s.snake_case}=", nested_hash_value(json, key.to_s))
        @to_h&.merge!({ key.to_s.snake_case.to_sym => self.send("#{key.to_s.snake_case}") })
      end
      yield self if block_given?
      self
    end

    # Builds an instance variable as well as its class method accessors from a key value pair.
    def accessor_builder(k, v)
      self.instance_variable_set("@#{k}", v)
      self.class.send(:define_method, "#{k}", proc { self.instance_variable_get("@#{k}") })
      self.class.send(:define_method, "#{k}=", proc { |v| self.instance_variable_set("@#{k}", v) })
    end

    #Goes through a complex Hash nest and gets the value of a passed key.
    # First wil check whether the object has the key? method,
    # which will mean it's a Hash and also if the Hash the method parameter key
    #   if obj.respond_to?(:key?) && obj.key?(key)
    #
    # If result object is a hash itself, will call constructor method to parse this hash first.
    #
    #   obj[key].is_a?(Hash) ? self.class.new(obj[key]) : obj[key]
    #
    # If it's not a Hash will check if it's a Array instead,
    # checking out whether it responds to a Array.each method or not.
    #   elsif obj.respond_to?(:each)
    #
    # For every Array found it make a recursive call to itself passing
    # the last element of the array and the Key it's looking for.
    #   r = nested_hash_value(a.last, key)
    def nested_hash_value(obj, key)
      if obj.respond_to?(:key?) && obj.key?(key)
        obj[key].is_a?(Hash) ? self.class.new(obj[key]) : obj[key]
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

    def attribute_from_inner_key(elem, attr, in_key = nil)
      { attr.to_sym => nested_hash_value(elem, in_key&.present? ? in_key : attr.to_s) }
    end

  end

  module Struct
    class Error < StandardError; end

    include Helper

    def initialize(json = nil)
      accessor_builder('to_h', {})
      json&.each do |k, v|
        self.send("#{k}=", v)
      end
    end

    def method_missing(name, *args)
      attribute = name.to_s.start_with?(/\d/) ? "_#{name.to_s}" : name.to_s
      if attribute =~ /=$/
        if args[0].respond_to?(:key?) || args[0].is_a?(Hash)
          @to_h[attribute.chop] = self.class.new(args[0])
        else
          @to_h[attribute.chop] = args[0]
        end
      else
        @to_h[attribute]
      end
    end
  end

  module Builder
    class Error < StandardError; end

    include Helper
    alias_method :initialize, :build_by_keys
  end

end
