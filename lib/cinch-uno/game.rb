module Uno
  class Game
    attr_reader :state
    attr_reader :discard_pile
    attr_reader :draw_pile
    attr_reader :players

    def current_player
      @players[@current_player_index]
    end

    def initialize
      @state = :waiting_to_start

      @deck = Deck.generate
      @players = []
    end

    def start
      raise GameHasStartedError unless @state == :waiting_to_start
      raise NotEnoughPlayersError unless @players.count >= 2

      @deck.shuffle!
      @discard_pile = [@deck.pop]
      @draw_pile = @deck

      @players.shuffle
      @current_player_index = 0

      @players.each do |player|
        player.empty_hand!

        7.times do
          player.put_card_in_hand @draw_pile.pop
        end
      end

      @state = :waiting_for_player_to_move
    end

    def add_player(player)
      raise GameIsOverError if @state == :game_over
      raise GameHasStartedError unless @state == :waiting_to_start

      @players << player unless players.include?(player)
    end

    def play(player, card_played)
      raise GameIsOverError if @state == :game_over
      raise GameHasNotStartedError unless @state == :waiting_for_player_to_move
      raise NotPlayersTurnError unless player == current_player
      raise PlayerDoesNotHaveThatCardError unless player.has_card?(card_played)
      raise InvalidMoveError unless Rules.card_can_be_played?(card_played, discard_pile)

      skip_next_player if Rules.next_player_is_skipped?(card_played, @players.count)
      reverse_play_order if Rules.play_is_reversed?(card_played, @players.count)

      @discard_pile.push current_player.take_card_from_hand(card_played)

      @state = :game_over if current_player.hand.size == 0

      move_to_next_player
    end

    def skip(player)
      raise NotPlayersTurnError if player != current_player

      current_player.put_card_in_hand @draw_pile.pop

      move_to_next_player
    end

    private

    def skip_next_player
      move_to_next_player
    end

    def move_to_next_player
      @current_player_index = ((@current_player_index + 1) % @players.length)
    end

    def reverse_play_order
      @players = @players.reverse
    end
  end
end