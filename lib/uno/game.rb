module Uno
  class Game
    attr_reader :discard_pile
    attr_reader :draw_pile
    attr_reader :players

    def state
      @state.state
    end

    def current_player
      @players[@current_player_index]
    end

    def next_player
      @players[next_player_index]
    end

    def initialize
      @state = GameState.new
      @state.set(:waiting_to_start)

      @deck = Deck.generate
      @players = []
    end

    def start
      raise GameHasStartedError unless @state.is? :waiting_to_start
      raise NotEnoughPlayersError unless players.count >= 2

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

      @state.set(:waiting_for_player_to_move)
    end

    def add_player(player)
      raise GameIsOverError if @state.is? :game_over
      raise GameHasStartedError unless @state.is? :waiting_to_start

      @players << player unless players.include?(player)
    end

    def play(player, card_played, color_choice = nil)
      raise GameIsOverError if @state.is? :game_over
      raise GameHasNotStartedError unless @state.game_in_progress?
      raise NotPlayersTurnError unless player == current_player
      raise WaitingForWD4ResponseError if @state.is? :awaiting_wd4_response
      raise PlayerDoesNotHaveThatCardError unless player.has_card?(card_played)
      raise NoColorChosenError if card_played.wild? && color_choice.nil?
      raise InvalidColorChoiceError if color_choice && !Card.colors.include?(color_choice)
      raise InvalidMoveError unless Rules.card_can_be_played?(card_played, discard_pile)

      @discard_pile.push current_player.take_card_from_hand(card_played)
      @state.set(:game_over) if current_player.hand.size == 0

      # Apply any special actions the card demands
      @players = @players.reverse if Rules.play_is_reversed?(card_played, @players.count)
      2.times {next_player.put_card_in_hand @draw_pile.pop} if Rules.next_player_must_draw_two?(card_played)
      card_played.color = color_choice if Rules.card_played_changes_color?(card_played)
      @state.set(:awaiting_wd4_response) if Rules.card_initiates_a_challenge?(card_played)

      skip_next_player if Rules.next_player_is_skipped?(card_played, @players.count)
      move_to_next_player
    end

    def skip(player)
      raise NotPlayersTurnError if player != current_player
      raise GameHasNotStartedError unless @state.game_in_progress?
      raise WaitingForWD4ResponseError if @state.is? :awaiting_wd4_response

      current_player.put_card_in_hand @draw_pile.pop

      move_to_next_player
    end

    def challenge(challenger)
      raise NoWD4ChallengeActiveError.new unless @state.is? :awaiting_wd4_response
      raise NotPlayersTurnError unless challenger == next_player

      if Rules.wd4_was_played_legally?(current_player.hand, discard_pile)
        6.times {next_player.put_card_in_hand @draw_pile.pop}
      else
        4.times {current_player.put_card_in_hand @draw_pile.pop}
        move_to_next_player
      end

      @state.set(:waiting_for_player_to_move)
    end

    def accept(challenger)
      raise NoWD4ChallengeActiveError.new unless @state.is? :awaiting_wd4_response
      raise NotPlayersTurnError unless challenger == next_player

      4.times {next_player.put_card_in_hand @draw_pile.pop}

      @state.set(:waiting_for_player_to_move)
    end

    private

    def skip_next_player
      move_to_next_player
    end

    def move_to_next_player
      @current_player_index = next_player_index
    end

    def next_player_index
      (@current_player_index + 1) % players.count
    end

  end
end