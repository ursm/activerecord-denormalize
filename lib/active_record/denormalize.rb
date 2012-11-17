require 'activerecord-postgres-hstore'

module ActiveRecord::Denormalize
  class << self
    def included(builder)
      builder.valid_options << :denormalize
    end

    def extract_attributes(obj, keys)
      return {} unless obj

      keys.each_with_object({}) {|key, hash|
        case key
        when Hash
          key.each do |k, v|
            hash[k] = v.is_a?(Proc) ? obj.instance_exec(&v) : obj.__send__(v)
          end
        else
          hash[key] = obj.__send__(key)
        end
      }
    end
  end

  def build
    super.tap {|reflection|
      configure_denormalize reflection
    }
  end

  private

  def configure_denormalize(reflection)
    return unless opts = options[:denormalize]

    dest_class  = reflection.klass
    source_name = options[:as] || reflection.source_reflection.options[:as]

    attributes = opts[:attributes]
    store_in   = opts[:store_in]   || "_#{source_name}"
    prefix     = opts[:prefix]     || "#{source_name}_"

    define_denormalize_to_method   attributes, store_in
    define_denormalize_from_method dest_class, source_name, attributes, store_in
    define_denormalize_readers     dest_class, attributes, prefix, store_in
  end

  def define_denormalize_to_method(attributes, store_in)
    dest_name   = name
    method_name = "denormalize_to_#{dest_name}"

    mixin.redefine_method method_name do
      attrs = ActiveRecord::Denormalize.extract_attributes(self, attributes)

      __send__(dest_name).update_all ["#{store_in} = ?::hstore", attrs.to_hstore]
    end

    model.after_save method_name
  end

  def define_denormalize_from_method(dest_class, source_name, attributes, store_in)
    method_name = "denormalize_from_#{source_name}"

    dest_class.redefine_method method_name do
      source = __send__(source_name)
      attrs  = ActiveRecord::Denormalize.extract_attributes(source, attributes)

      self[store_in] = attrs.stringify_keys
    end

    dest_class.before_create method_name
  end

  def define_denormalize_readers(dest_class, attributes, prefix, store_in)
    attributes.each do |attr|
      case attr
      when Hash
        attr.each_key do |key|
          define_denormalize_reader dest_class, key, prefix, store_in
        end
      else
        define_denormalize_reader dest_class, attr, prefix, store_in
      end
    end
  end

  def define_denormalize_reader(dest_class, name, prefix, store_in)
    dest_class.class_eval <<-RUBY
      def #{prefix}#{name}
        #{store_in}[#{name.to_s.inspect}]
      end
    RUBY
  end
end
