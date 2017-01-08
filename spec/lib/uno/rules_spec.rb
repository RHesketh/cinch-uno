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

      describe "Special cards" do
        describe "Wild" do
          it "Can be played on top of any card" do
            card = Card.new(:wild)
            discarded_card = Card.new(:two, :red)
            discard_pile = [discarded_card]

            expect(Rules.card_can_be_played?(card, discard_pile)).to eq true
          end
        end

        describe "Wild Draw Four" do
          it "Can be played on top of any card" do
            card = Card.new(:wild_draw_four)
            discarded_card = Card.new(:two, :red)
            discard_pile = [discarded_card]

            expect(Rules.card_can_be_played?(card, discard_pile)).to eq true
          end
        end
      end
    end

    describe "next_player_is_skipped?(card, player_count)" do
      it "Wild Draw Four cards cause the next player to skip their turn" do
        expect(Rules.next_player_is_skipped?(Card.new(:wild_draw_four, :blue), 2)).to eq true
      end

      it "Wild cards don't cause the next player to skip their turn" do
        expect(Rules.next_player_is_skipped?(Card.new(:wild, :blue), 2)).to eq false
      end

      it "Draw two cards cause the next player to skip their turn" do
        expect(Rules.next_player_is_skipped?(Card.new(:draw_two, :blue), 2)).to eq true
      end

      it "Skip cards cause the next player to skip their turn" do
        expect(Rules.next_player_is_skipped?(Card.new(:skip, :blue), 2)).to eq true
      end

      it "Normal cards don't cause the next player to skip their turn" do
        expect(Rules.next_player_is_skipped?(Card.new(:two, :blue), 2)).to eq false
      end

      context "When two people are playing" do
        it "Reverse cards cause the next player to skip their turn" do
          expect(Rules.next_player_is_skipped?(Card.new(:reverse, :blue), 2)).to eq true
        end
      end

      context "When more than two people are playing" do
        it "Reverse cards don't cause the next player to skip their turn" do
          expect(Rules.next_player_is_skipped?(Card.new(:reverse, :blue), 3)).to eq false
        end
      end
    end

    describe "#play_is_reversed?(card, player_count)" do
      it "Normal cards don't cause the play order to be reversed" do
        expect(Rules.play_is_reversed?(Card.new(:two, :blue), 2)).to eq false
      end

      context "When two people are playing" do
        it "Reverse cards don't cause the play order to be reversed" do
          expect(Rules.play_is_reversed?(Card.new(:reverse, :blue), 2)).to eq false
        end
      end

      context "When more than two people are playing" do
        it "Reverse cards cause the play order to be reversed" do
          expect(Rules.play_is_reversed?(Card.new(:reverse, :blue), 3)).to eq true
        end
      end
    end

    describe "#next_player_must_draw_two?(card_played)" do
        it "Draw two cards cause the player to pick up two" do
          expect(Rules.next_player_must_draw_two?(Card.new(:draw_two, :blue))).to eq true
        end

        it "Any other cards don't cause the player to pick up two" do
          expect(Rules.next_player_must_draw_two?(Card.new(:two, :blue))).to eq false
        end
    end

    describe "#card_played_changes_color?" do
      it "Wild cards change to the specified color" do
        expect(Rules.card_played_changes_color?(Card.new(:wild))).to eq true
      end

      it "Wild Draw Four cards change to the specified color" do
        expect(Rules.card_played_changes_color?(Card.new(:wild_draw_four))).to eq true
      end

      it "Normal cards don't change to the specified color" do
        expect(Rules.card_played_changes_color?(Card.new(:four, :green))).to eq false
      end
    end

    describe "#card_initiates_a_challenge?" do
      it "Wild Draw Four cards initiate an automatic challenge" do
        expect(Rules.card_initiates_a_challenge?(Card.new(:wild_draw_four))).to eq true
      end

      it "Normal cards don't initiate an automatic challenge" do
        expect(Rules.card_initiates_a_challenge?(Card.new(:four, :blue))).to eq false
      end
    end

    describe "#wd4_was_played_legally?(wd4_players_hand, discard_pile)" do
      describe "WD4 player has a card matching the colour of the card before WD4" do
        it "Is not a legal play" do
          hand = [Card.new(:five, :red)]
          discard_pile = [Card.new(:wild_draw_four), Card.new(:four, :red)]
          expect(Rules.wd4_was_played_legally?(hand, discard_pile)).to eq false
        end
      end

      describe "WD4 player has no cards matching the colour of the card before WD4" do
        it "Is a legal play" do
          hand = [Card.new(:five, :blue)]
          discard_pile = [Card.new(:wild_draw_four), Card.new(:four, :red)]
          expect(Rules.wd4_was_played_legally?(hand, discard_pile)).to eq true
        end
      end
    end
  end
end