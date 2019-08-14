module Ruby
  module Plugin
    # To be included in each class that talks to the 3rd party API
    module MessageHandler # remove
      def self.call(*args)
        fail
      end
    end
  end
end
