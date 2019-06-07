# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

require 'pry'

class Factory
  def self.new(*arguments, &block)
    Class.new do
      attr_accessor(*arguments)

      define_method :attributes do
        arguments
      end

      define_method :initialize do |*arg|
        if attributes.count == arg.count
          hash = attributes.zip(arg)
          hash.each do |key, value|
            instance_variable_set("@#{key}", value)
          end
        end
      end

      define_method :[] do |value|
        return instance_variable_get(instance_variables[value]) if value.is_a? Integer

        instance_variable_get "@#{value}"
      end

      define_method :dig do |*args|
        args.inject(self) { |values, key| values[key] if values }
      end

      define_method :[]= do |value, arg|
        return instance_variable_set(instance_variables[value], arg) if value.is_a? Integer

        instance_variable_set("@#{value}", arg) if (value.is_a? String) || (value.is_a? Symbol)
      end

      define_method :each do |&block|
        to_a.each(&block)
      end

      define_method :select do |&block|
        to_a.select(&block)
      end

      define_method :each_pair do |&block|
        Hash[members.zip(to_a)].each_pair(&block)
      end

      define_method :length do
        instance_variables.size
      end

      define_method :members do
        instance_variables.to_a
      end

      define_method :values_at do |*args|
        instance_variables.values_at(*args).map { |value| instance_variable_get value }
      end

      define_method :to_a do
        instance_variables.map { |value| instance_variable_get value }
      end

      define_method :== do |object|
        (self.class == object.class) && (to_a == object.to_a)
      end

      class_eval(&block) if block_given?
      alias_method :size, :length
      alias_method :eql?, :==
    end
  end
end
