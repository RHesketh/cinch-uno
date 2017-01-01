require 'spec_helper'

module Uno
  describe Rules do
    describe "card_can_be_played?(card, discard_pile)" do
      describe "Normal cards" do
        it "Card can be played if it matches color with the top card on the discard pile" do
          card = Card.new(:two, :blue)
          discarded_card = Card.new(:three, :blue)
          discard_pile = [discarded_card]

          expect(Rules.card_can_be_played?(card, discard_pile)).to eq true
        end

        it "Card can be played if it matches type with the top card on the discard pile" do
          card = Card.new(:two, :blue)
          discarded_card = Card.new(:two, :red)
          discard_pile = [discarded_card]

          expect(Rules.card_can_be_played?(card, discard_pile)).to eq true
        end

        it "Card cannot be played if it does not match color or type with the top card on the discard pile" do
          card = Card.new(:two, :blue)
          discarded_card = Card.new(:three, :red)
          discard_pile = [discarded_card]

          expect(Rules.card_can_be_played?(card, discard_pile)).to eq false
        end
      end
    end
  end
end