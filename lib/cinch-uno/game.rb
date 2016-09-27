module Uno
  class Game
    attr_reader :state
    attr_reader :discard_pile
    attr_reader :draw_pile
    attr_reader :play_order
    
    def players
      @players.keys
    end

    def current_player
      @play_order[@current_player]
    end

    def initialize(options={})
      @state =          :waiting_to_start


      @deck =           options[:deck]      || Uno::Deck.generate
      @players =        options[:players]   || {}
    end

    def start
      raise NotEnoughPlayers unless @players.keys.count >= 2 

      @deck.shuffle!

      @discard_pile = [@deck.pop]
      @draw_pile = @deck
      @play_order = @players.keys.shuffle
      @current_player = 0

      @state = :waiting_for_player
    end

    def add_player(nickname)
      @players[nickname] = {}
    end

    # Errors
    class NotEnoughPlayers < StandardError; end
    class PlayerAlreadyInGame < StandardError; end
  end
end