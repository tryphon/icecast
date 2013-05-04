module Icecast
  class NullCache
    
    def fetch(*arguments, &block)
      yield
    end
    
  end
end
