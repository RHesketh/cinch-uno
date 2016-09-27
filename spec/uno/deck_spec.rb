require 'spec_helper'

module Uno
  describe Deck do
    describe "#generate" do
      it 'Returns an array of cards' do
        deck = Uno::Deck.generate
        
        expect(deck).to be_an Array
        expect(deck.first).to be_a Uno::Card
      end
    end
  end
end