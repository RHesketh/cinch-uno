module Uno
  class Rules
    class << self
      def card_can_be_played?(card_played, discard_pile)
        return true if card_played.type == :wild
        return true if card_played.type == :wild_draw_four
        top_card = discard_pile.last

        return true if card_played.type == top_card.type
        return true if card_played.color == top_card.color

        return false
      end

      def next_player_is_skipped?(card_played, player_count)
        return true if card_played.type == :skip
        return true if card_played.type == :reverse && player_count <= 2
        return true if card_played.type == :draw_two

        return false
      end

      def play_is_reversed?(card_played, player_count)
        return false if player_count <= 2
        return true if card_played.type == :reverse

        return false
      end

      def next_player_must_draw_two?(card_played)
        return true if card_played.type == :draw_two
        return false
      end

      def card_played_changes_color?(card_played)
        return true if card_played.type == :wild
        return true if card_played.type == :wild_draw_four
        return false
      end

      def card_initiates_a_challenge?(card_played)
        return true if card_played.type == :wild_draw_four
        return false
      end
    end
  end
end