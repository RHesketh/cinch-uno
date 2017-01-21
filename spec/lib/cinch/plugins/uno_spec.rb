require 'spec_helper'
require 'cinch/test'
require './lib/cinch/plugins/uno'

include Cinch::Test

module Cinch
  module Plugins
    describe Uno do
      subject { make_bot(Cinch::Plugins::Uno) }

      it "Starter test - delete me" do
        sent_message = make_message(subject, '!fart')

        replies = get_replies(sent_message)
        puts "*** #{replies.count} replies!"
        replies.each do |reply|
          puts reply.text
        end
      end
    end
  end
end