module Uno
  class Game
    attr_reader :state
    attr_reader :discard_pile
    attr_reader :draw_pile
    attr_reader :play_order
    attr_reader :players

    def current_player
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
      @play_order = options[:static_play_order] != false ? @players.keys : @players.keys.shuffle
      @current_player = 0

      deal_starting_cards_to_all_players if @players[current_player][:cards].nil?

      @state = :waiting_for_player
    end

    def add_player(nickname)
      raise GameIsOver if @state == :game_over
      raise GameHasStarted unless @state == :waiting_to_start
      @players[nickname] = {}
    end

    def play(player_name, card_played)
      raise GameIsOver if @state == :game_over
      raise GameHasNotStarted unless @state == :waiting_for_player
      raise NotPlayersTurn unless current_player == player_name

      removed_card = remove_card_from_hand(player_name, card_played)
      raise PlayerDoesNotHaveThatCard if removed_card.nil?

      top_card = discard_pile.last

      raise InvalidMove if (card_played.type != top_card.type && card_played.color != top_card.color)
      move_to_next_player if card_played.type == :skip || removed_card.type == :reverse && @players.count <= 2
      reverse_play_order if card_played.type == :reverse && @players.count > 2

      @discard_pile.push removed_card

      @state = :game_over if player_has_no_cards_left(current_player)

      move_to_next_player
    end

    def skip(player_name)
      raise NotPlayersTurn if player_name != current_player

      @players[current_player][:cards] << @draw_pile.pop

      @current_player = ((@current_player + 1) % @players.length)
    end

    # Errors
    # Todo: Add "Error" onto all their names
    class GameHasNotStarted < StandardError; end
    class GameHasStarted < StandardError; end
    class NotEnoughPlayers < StandardError; end
    class PlayerAlreadyInGame < StandardError; end
    class NotPlayersTurn < StandardError; end
    class InvalidMove < StandardError; end
    class PlayerDoesNotHaveThatCard < StandardError; end 
    class GameIsOver < StandardError; end 

    private

    def move_to_next_player
      @current_player = ((@current_player + 1) % @players.length)
    end

    def reverse_play_order
      @play_order = @play_order.reverse
    end

    def player_has_no_cards_left(player_name)
      return true if players[player_name][:cards].count == 0
      return false
    end

    def remove_card_from_hand(player_name, card_played)
      index = players[player_name][:cards].find_index{|c| c == card_played}
      return nil if index.nil?
      players[player_name][:cards].delete_at(index)
    end

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