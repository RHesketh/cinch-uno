module Uno
  class Game
    attr_reader :state
    
    def players
      @players.keys
    end

    def initialize
      @state = :waiting_to_start
      @players = {}
    end

    def start
      raise NotEnoughPlayers unless @players.keys.count >= 2 

      @state = :waiting_for_player
    end

    def add_player(nickname)
      #raise PlayerAlreadyInGame if @players[nickname]

      @players[nickname] = {}

    end

    # Errors
    class NotEnoughPlayers < StandardError; end
    class PlayerAlreadyInGame < StandardError; end
  end
end