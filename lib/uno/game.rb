require "observer"

module Uno
  class Game
    include Observable
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
      set_game_state_to :waiting_to_start

      @deck = Deck.standard_uno_deck
      @players = []
    end

    def start
      raise_error_unless_game_is_waiting_to_start
      raise_error_if_there_are_not_enough_players

      set_up_draw_and_discard_piles
      establish_play_order
      deal_starting_cards
      set_game_state_to :waiting_for_player_to_move
    end

    def add_player(player)
      raise_error_unless_game_is_waiting_to_start

      @players << player unless players.include?(player)
    end

    def play(player, card_played, color_choice = nil)
      raise_error_if_game_is_not_in_progress
      raise_error_if_player_is_out_of_turn(current_player, player)
      raise_error_if_waiting_for_wild_draw_four_response
      raise_error_if_move_is_invalid(player, card_played, color_choice, discard_pile)

      put_played_card_onto_discard_pile(card_played)
      check_if_game_has_finished
      apply_game_rules(card_played, color_choice)
      move_to_next_player
    end

    def skip(player)
      raise_error_if_game_is_not_in_progress
      raise_error_if_player_is_out_of_turn(current_player, player)
      raise_error_if_waiting_for_wild_draw_four_response

      current_player.put_card_in_hand draw_card_from_draw_pile
      move_to_next_player
    end

    def challenge(challenger)
      raise_error_if_game_is_not_in_progress
      raise_error_if_player_is_out_of_turn(next_player, challenger)
      raise_error_unless_waiting_for_wild_draw_four_response

      if Rules.wd4_was_played_legally?(current_player.hand, discard_pile)
        draw_multiple_cards(next_player, 6)
      else
        draw_multiple_cards(current_player, 4)
        move_to_next_player
      end

      set_game_state_to :waiting_for_player_to_move
    end

    def accept(challenger)
      raise_error_if_game_is_not_in_progress
      raise_error_if_player_is_out_of_turn(next_player, challenger)
      raise_error_unless_waiting_for_wild_draw_four_response

      draw_multiple_cards(next_player, 4)

      set_game_state_to :waiting_for_player_to_move
    end

    private

    def set_up_draw_and_discard_piles
      @deck.shuffle!
      @discard_pile = [@deck.pop]
      @draw_pile = @deck
    end

    def establish_play_order
      @players.shuffle
      @current_player_index = 0
    end

    def deal_starting_cards
      @players.each do |player|
        player.remove_all_cards_from_hand!

        draw_multiple_cards(player, 7)
      end
    end

    def apply_game_rules(card_played, color_choice)
      reverse_play_order if Rules.play_is_reversed?(card_played, @players.count)
      draw_multiple_cards(next_player, 2) if Rules.next_player_must_draw_two?(card_played)
      card_played.color = color_choice if Rules.card_played_changes_color?(card_played)
      @state.set(:awaiting_wd4_response) if Rules.card_initiates_a_challenge?(card_played)
      skip_next_player if Rules.next_player_is_skipped?(card_played, @players.count)
    end

    def draw_card_from_draw_pile
      drawn_card = @draw_pile.pop

      if @draw_pile.empty?
        reshuffle_discard_pile_into_draw_pile
        notify_observers(:draw_pile_empty)
      end

      drawn_card
    end

    def reshuffle_discard_pile_into_draw_pile
        top_card = @discard_pile.pop
        @draw_pile = @discard_pile.shuffle
        @discard_pile = [top_card]
    end

    def put_played_card_onto_discard_pile(card_played)
      current_player.take_card_from_hand(card_played)
      @discard_pile.push card_played
    end

    def reverse_play_order
      @players = @players.reverse
    end

    def draw_multiple_cards(player, draw_count)
      draw_count.times do
        player.put_card_in_hand draw_card_from_draw_pile
      end
    end

    def skip_next_player
      move_to_next_player
    end

    def move_to_next_player
      @current_player_index = next_player_index
    end

    def next_player_index
      (@current_player_index + 1) % players.count
    end

    def set_game_state_to(new_state)
      @state.set new_state
    end

    def check_if_game_has_finished
      set_game_state_to :game_over if current_player.hand.empty?
    end

    def raise_error_if_game_is_not_in_progress
      raise GameIsOverError if @state.is? :game_over
      raise GameHasNotStartedError unless @state.game_in_progress?
    end

    def raise_error_if_player_is_out_of_turn(expected, actual)
      raise NotPlayersTurnError unless expected == actual
    end

    def raise_error_unless_game_is_waiting_to_start
      raise GameIsOverError if @state.is? :game_over
      raise GameHasStartedError unless @state.is? :waiting_to_start
    end

    def raise_error_if_there_are_not_enough_players
      raise NotEnoughPlayersError unless players.count >= 2
    end

    def raise_error_if_move_is_invalid(player, card_played, color_choice, discard_pile)
      raise PlayerDoesNotHaveThatCardError unless player.has_card?(card_played)
      raise NoColorChosenError if card_played.wild? && color_choice.nil?
      raise InvalidColorChoiceError if color_choice && !Card.colors.include?(color_choice)
      raise InvalidMoveError unless Rules.card_can_be_played?(card_played, discard_pile)
    end

    def raise_error_if_waiting_for_wild_draw_four_response
      raise WaitingForWD4ResponseError if @state.is? :awaiting_wd4_response
    end

    def raise_error_unless_waiting_for_wild_draw_four_response
      raise NoWD4ChallengeActiveError unless @state.is? :awaiting_wd4_response
    end
  end
end