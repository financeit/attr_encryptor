if defined?(ActiveRecord::Base)
  module AttrEncryptor
    module Adapters
      module ActiveRecord
        def self.extended(base) # :nodoc:
          base.class_eval do
            class << self
              alias_method :attr_encrypted_without_defined_attributes, :attr_encrypted
              alias_method :attr_encrypted, :attr_encrypted_with_defined_attributes

              alias_method :attr_encryptor_without_defined_attributes, :attr_encrypted
              alias_method :attr_encryptor, :attr_encrypted_with_defined_attributes

            end

            attr_encrypted_options[:encode] = true
          end
        end

        protected

        # Ensures the attribute methods for db fields have been defined before calling the original 
        # <tt>attr_encrypted</tt> method
        def attr_encrypted_with_defined_attributes(*attrs)
          define_attribute_methods rescue nil
          attr_encrypted_without_defined_attributes *attrs
          attrs.reject { |attr| attr.is_a?(Hash) }.each { |attr| alias_method "#{attr}_before_type_cast", attr }
        end

        alias attr_encryptor_with_defined_attributes attr_encrypted_with_defined_attributes
      end
    end
  end

  ActiveRecord::Base.extend AttrEncryptor::Adapters::ActiveRecord
end
