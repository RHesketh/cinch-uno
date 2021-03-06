require 'spec_helper'

module Uno
  describe Card do
    describe "#==(Card)" do
      it "Returns true when two cards match type and color" do
         card_1 = Card.new(:one, :blue)
         card_2 = Card.new(:one, :blue)

         expect(card_1 == card_2).to eq true
      end

      it "Returns false when the color is not a match" do
         card_1 = Card.new(:one, :blue)
         card_2 = Card.new(:one, :red)

         expect(card_1 == card_2).to eq false
      end

      it "Returns false when the type is not a match" do
         card_1 = Card.new(:two, :blue)
         card_2 = Card.new(:one, :blue)

         expect(card_1 == card_2).to eq false
      end
    end

    describe "#wild?" do
      it "Returns true when the card is wild" do
           expect(Card.new(:wild).wild?).to eq true
           expect(Card.new(:wild_draw_four, :blue).wild?).to eq true
      end

      it "Returns false when the card is not wild" do
        expect(Card.new(:five, :blue).wild?).to eq false
        expect(Card.new(:skip, :blue).wild?).to eq false
        expect(Card.new(:draw_two, :blue).wild?).to eq false
      end
    end
  end
end