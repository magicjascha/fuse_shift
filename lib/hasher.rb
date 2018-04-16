module Hasher  
  def digest(string)
    Digest::SHA2.hexdigest(string)
  end
end