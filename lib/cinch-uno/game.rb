module Uno
  class Game
    attr_reader :state

    def initialize
      @state = :waiting_for_players
    end
  end
end