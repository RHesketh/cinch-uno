module Uno
  class GameState
    attr_reader :state

    def is?(comparison_state)
      state == comparison_state
    end

    def set(new_state)
      raise TypeError.new("State must be a symbol") unless new_state.is_a? Symbol
      raise ArgumentError.new("State must be one of: #{states.join(" ")}") unless states.include?(new_state)
      @state = new_state
    end

    def states
      [:waiting_to_start, :waiting_for_player_to_move, :awaiting_wd4_response, :game_over]
    end

    # Helper methods
    def game_in_progress?
      return true if [:waiting_for_player_to_move, :awaiting_wd4_response].include?(state)
      return false
    end
  end
end