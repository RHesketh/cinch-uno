require 'spec_helper'

module Uno
  describe MessageHandler do
    # It takes in strings from IRC clients and translates them into Uno game objects.
    # It has no logic of its own, all it does is takes the input the IRC handler recognised and
    # Turns it into classes like Player and Card

    # Also handles outgoing stuff i.e. turning Card objects into cool IRC representations
    # Also outgoing means translating the game's exceptions into human-readable messages
  end
end