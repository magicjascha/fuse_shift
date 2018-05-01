require 'openssl'
require 'base64'
require 'encrypt/base'

module Encrypt
  class Encryptor < Base
    def apply?
      !!string && !string.empty?
    end

    def apply
      apply? ? encrypt : string
    end
    
    private

      def encrypt
        encode(rsa.public_encrypt(string))
      end
  end
end