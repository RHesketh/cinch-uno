module Cinch
  module Plugins
    class Uno
      include Cinch::Plugin

      match /fart/i, method: :help

      def help(m)
        m.reply("Farting.")
      end
    end
  end
end