module Uno
  class Rules
    class << self
      def card_can_be_played?(card_played, discard_pile)
        top_card = discard_pile.last

        return true if card_played.type == top_card.type
        return true if card_played.color == top_card.color

        return false
      end
    end
  end
end