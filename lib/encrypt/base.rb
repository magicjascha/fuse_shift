module Encrypt
  class Base
    attr_reader :string, :key

    def initialize(string, key)
      @string = string
      @key    = key
      validate
    end

    private

      def encode(str)
        Base64.strict_encode64(str)
      end

      def decode(str)
        Base64.strict_decode64(str)
      end
      
      def rsa
        OpenSSL::PKey::RSA.new(key)
      end

      # def validate
      #   key               || fail('No key given')
      #   key.is_a?(String) || fail("Invalid key given: #{key.inspect}")
      # end

      def validate
        fail('No key given') if key.nil?
        fail("Invalid key given: #{key.inspect}") unless key.is_a?(String)
      end
  end
end