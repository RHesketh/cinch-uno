require 'spec_helper'
require 'cinch/test'
require './lib/cinch/plugins/uno'

include Cinch::Test

module Cinch
  module Plugins
    describe Uno do

      it "Starter test - delete me" do
        test_bot = make_bot(Cinch::Plugins::Uno)

        sent_message = make_message(test_bot, 'hey bro')

        get_replies(sent_message).each do |reply|
          puts reply
        end
      end
    end
  end
end