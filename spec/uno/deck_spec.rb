require 'spec_helper'

module Uno
  describe Deck do
    describe "#generate" do
      let(:colors){[:red, :blue, :green, :yellow]}
      let(:deck) { Uno::Deck.generate }

      it 'Returns an array of cards' do
        expect(deck).to be_an Array
        expect(deck.first).to be_a Uno::Card
      end

      it "Includes 108 cards in total" do
        expect(deck.length).to eq 108
      end

      it "Includes 1x card numbering 0 for each color" do
        colors.each do |color|
          this_color = deck.select{|c| c.color == color }

          zeroes = this_color.select{|c| c.type == :zero }.length

          expect(zeroes).to eq 1
        end
      end

      it "Includes 2x cards numbering 1-9 for each color" do
        colors.each do |color|
          [:one, :two, :three, :four, :five, :six, :seven, :eight, :nine].each do |number|
            expect(deck.select{|c| c.color == color }.select{|c| c.type == number }.length).to eq 2
          end
        end
      end

      it "Includes 2x Draw Two cards for each color" do
        colors.each do |color|
          expect(deck.select{|c| c.color == color }.select{|c| c.type == :draw_two }.length).to eq 2
        end
      end

      it "Includes 2x Reverse cards for each color" do
        colors.each do |color|
          expect(deck.select{|c| c.color == color }.select{|c| c.type == :reverse }.length).to eq 2
        end
      end

      it "Includes 2x Skip cards for each color" do
        colors.each do |color|
          expect(deck.select{|c| c.color == color }.select{|c| c.type == :skip }.length).to eq 2
        end
      end

      it "Includes 4x Wild cards" do
        expect(deck.select{|c| c.type == :wild }.length).to eq 4
      end

      it "Includes 4x Wild Draw Four cards" do
        expect(deck.select{|c| c.type == :wild_draw_four }.length).to eq 4
      end
    end
  end
end