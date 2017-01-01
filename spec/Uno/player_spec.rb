require 'spec_helper'

module Uno
  describe Player do
    let(:subject) { Player.new("Char")}

    it "has a #hand attribute" do
      expect(subject).to have_attributes(:hand => [])
    end

    it "has a #name attribute" do
      expect(subject).to have_attributes(:name => "Char")
    end

    describe "#put_card_in_hand(Card)" do
      it "Adds the given card to the player's hand" do
        card = Card.new(:two, :blue)

        subject.put_card_in_hand(card)

        expect(subject.hand.last).to eq card
      end
    end

    describe "#has_card?" do
      it "is true when the player has that card in their hand" do
        card = Card.new(:two, :blue)
        subject.put_card_in_hand(card)

        expect(subject.has_card?(card)).to eq true
      end

      it "is false when the player does not have that their card in their hand" do
        card = Card.new(:two, :blue)
        subject.put_card_in_hand(card)
        another_card = Card.new(:three, :blue)

        expect(subject.has_card?(another_card)).to eq false
      end
    end
  end
end