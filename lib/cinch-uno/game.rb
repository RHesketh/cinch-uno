module Uno
  class Game
    attr_reader :state
    attr_reader :discard_pile
    attr_reader :draw_pile
    attr_reader :play_order
    attr_reader :players
    

    def current_player_name
      @play_order[@current_player]
    end

    def initialize(options={})
      @state =          :waiting_to_start


      @deck =               options[:deck]      || Uno::Deck.generate
      @players =            options[:players]   || {}
    end

    def start(options={})
      raise NotEnoughPlayers unless @players.count >= 2 

      @deck.shuffle! unless options[:shuffle_deck] == false

      @discard_pile = [@deck.pop]
      @draw_pile = @deck
      @play_order = options[:static_play_order] == false ? @players.keys : @players.keys.shuffle
      @current_player = 0

      deal_starting_cards_to_all_players if @players[current_player_name][:cards].nil?

      @state = :waiting_for_player
    end

    def add_player(nickname)
      @players[nickname] = {}
    end

    def play(player_name, card_played)
      raise GameHasNotStarted unless @state == :waiting_for_player
      raise NotPlayersTurn unless current_player_name == player_name

      top_card = discard_pile.last
      raise InvalidMove if (card_played.type != top_card.type && card_played.color != top_card.color)
    end

    # Errors
    class GameHasNotStarted < StandardError; end
    class NotEnoughPlayers < StandardError; end
    class PlayerAlreadyInGame < StandardError; end
    class NotPlayersTurn < StandardError; end
    class InvalidMove < StandardError; end

    private 

    def deal_starting_cards_to_all_players
      @players.keys.each do |player|
        @players[player][:cards] = []

        7.times do
          @players[player][:cards] << @draw_pile.pop
        end
      end
    end
  end
end