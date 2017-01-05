require_relative 'uno/message_handler'

module Cinch
  module Plugins
    # Interfaces with Cinch and IRC chatters
    class Uno
      include Cinch::Plugin

      match /fart/i, method: :help

      def help(m)
        m.reply("Farting.")
      end
    end
  end
end