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

    describe "#empty_hand!" do
      it "Removes all cards from the player's hand" do
        card = Card.new(:two, :blue)

        subject.put_card_in_hand(card)

        subject.empty_hand!

        expect(subject.hand.size).to eq 0
      end
    end

    describe "#take_card_from_hand(Card)" do
      it "Removes the given card from the player's hand" do
        first_card = Card.new(:two, :blue)
        removed_card = Card.new(:red, :four)

        subject.put_card_in_hand first_card
        subject.put_card_in_hand removed_card

        subject.take_card_from_hand(removed_card)

        expect(subject.has_card?(first_card)).to eq true
        expect(subject.has_card?(removed_card)).to eq false
      end

      it "Returns the card that was removed" do
        card = Card.new(:two, :blue)

        subject.put_card_in_hand card
        removed = subject.take_card_from_hand(card)

        expect(removed).to be_a Card
        expect(removed == card).to eq true
      end

      it "Raises an error if the player does not have that card" do
        card = Card.new(:two, :blue)
        other_card = Card.new(:four, :red)

        subject.put_card_in_hand(card)
        expect {
          subject.take_card_from_hand(other_card)
          }.to raise_error(PlayerDoesNotHaveThatCardError)
      end
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