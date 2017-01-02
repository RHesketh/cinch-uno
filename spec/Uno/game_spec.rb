require 'spec_helper'

module Uno
  describe Game do
    let(:game) { Uno::Game.new }

    it 'Starts in a :waiting_to_start state' do
      expect(game.state).to be :waiting_to_start
    end

    context "While waiting to start..." do
      it "Don't start the game unless there are at least 2 players" do
        expect{
          game.start
        }.to raise_error(NotEnoughPlayersError)
      end

      it "Allow multiple players to join the game" do
        game.add_player("Char")
        game.add_player("angelphish")

        expect(game.players).to be_an Array

        expect(game.players[0]).to eq "Char"
        expect(game.players[1]).to eq "angelphish"

        expect(game.players.length).to eq 2
      end

      it "Do nothing if a player tries to join twice" do
        game.add_player("Char")
        game.add_player("Char")

        expect(game.players.length).to eq 1
      end

      it "Moves are not accepted" do
        expect{
          game.play("foo12", Uno::Card.new)
        }.to raise_error(GameHasNotStartedError)
      end
    end

    context "When the game is started with at least two players..." do
      let(:game){ Uno::Game.new }

      before(:each) do
        game.add_player Player.new("Char")
        game.add_player Player.new("angelphish")
      end

      it "Generate a deck to play with" do
        expect(Deck).to receive(:generate).and_call_original
        Uno::Game.new
      end

      it "Shuffle the deck" do
        expect_any_instance_of(Array).to receive(:shuffle!).and_call_original

        game.start
      end

      it "Deals 7 cards to each player" do
        game.start

        game.players.each do |player|
          expect(player.hand).to be_an Array
          expect(player.hand.size).to eq 7
        end
      end

      it "Place one card from the deck on the discard pile" do
        game.start

        expect(game.discard_pile).to be_an Array
        expect(game.discard_pile.length).to eq 1
        expect(game.discard_pile.last).to be_a Card
      end

      it "Place the remaining cards from the deck into a draw pile" do
        game.start

        expect(game.draw_pile).to be_an Array
        expect(game.draw_pile.length).to eq 93
        expect(game.draw_pile.last).to be_a Uno::Card
      end

      it "Determine a play order" do
        game.start

        expect(game.players).to be_an Array
        expect(game.players.count).to eq 2
      end

      it "Expose the current player" do
        game.start

        expect(game.current_player).to be_a Player
        expect(game.players.include?(game.current_player)).to be true
      end

      it "Begin in a :waiting_for_player_to_move state" do
        game.start
        expect(game.state).to be :waiting_for_player_to_move
      end

      it "Can't add players once the game has started" do
        game.start
        player_count = game.players.count

        new_player = Player.new("Gatecrasher")
        expect{game.add_player(new_player)}.to raise_error(GameHasStartedError)
        expect(game.players.count).to eq player_count
      end
    end

    context "Move validation" do
      let(:game){ Uno::Game.new}

      before(:each) do
        game.add_player(Player.new("Char"))
        game.add_player(Player.new("angelphish"))
        game.start
      end

      it "Moves are only accepted from players who are in the game" do
        gatecrasher = Player.new("foo12")

        expect{
          game.play(gatecrasher, Uno::Card.new)
        }.to raise_error(NotPlayersTurnError)
      end

      it "A player cannot move unless it is their turn" do
        expect(game.current_player).to eq game.players[0]
        queuejumper = game.players[1]

        expect{
          game.play(queuejumper, Uno::Card.new)
        }.to raise_error(NotPlayersTurnError)
      end

      it "A player cannot play a card that is not in their hand" do
        expect{
          game.play(game.players[0], Uno::Card.new(:zero, :yellow))
        }.to raise_error(PlayerDoesNotHaveThatCardError)
      end

      it "Valid move: Playing a card matching the color of the card on top of the discard pile" do
        fake_card = spy("Card")
        expect(fake_card).to receive(:type).and_return(:one)
        expect(fake_card).to receive(:color).and_return(:red)
        expect(game.discard_pile).to receive(:last).and_return(fake_card)
        expect(game.current_player).to receive(:has_card?).at_least(:once).and_return(true)

        expect{
          game.play(game.current_player, Uno::Card.new(:zero, :red))
        }.not_to raise_error
      end

      it "Valid move: Playing a card matching the number of the card on top of the discard pile" do
        fake_card = spy("Card")
        expect(fake_card).to receive(:type).and_return(:one)
        expect(game.discard_pile).to receive(:last).and_return(fake_card)
        expect(game.current_player).to receive(:has_card?).at_least(:once).and_return(true)

        expect{
          game.play(game.current_player, Uno::Card.new(:one, :blue))
        }.not_to raise_error
      end

      it "Invalid move: Playing a card that does not match the color or number of the card on top of the discard pile" do
        fake_card = spy("Card")
        expect(fake_card).to receive(:color).and_return(:red)
        expect(fake_card).to receive(:type).and_return(:one)
        expect(game.discard_pile).to receive(:last).and_return(fake_card)
        expect(game.current_player).to receive(:has_card?).at_least(:once).and_return(true)

        expect{
          game.play(game.current_player, Uno::Card.new(:three, :yellow))
        }.to raise_error(InvalidMoveError)
      end
    end

    context "When a player skips instead of taking their turn" do
      let(:game){ Uno::Game.new}

      before(:each) do
        game.add_player(Player.new("Char"))
        game.add_player(Player.new("angelphish"))
        game.start
      end

      it "Control goes to the next player" do
        current_player_index = game.players.find_index(game.current_player)
        next_player_index = current_player_index + 1 % game.players.count

        game.skip(game.current_player)

        expect(game.current_player).to eq game.players[next_player_index]
      end

      it "The skipping player picks up a card" do
        skipping_player = game.current_player
        number_of_cards_beforehand = skipping_player.hand.size

        game.skip(skipping_player)

        expect(skipping_player.hand.size).to be > number_of_cards_beforehand
      end

      it "A player cannot skip if it is not their turn" do
        expect(game.current_player).to eq game.players[0]

        expect{game.skip(game.players[1])}.to raise_error(NotPlayersTurnError)
      end

      it "A player cannot skip if they are not playing" do
        gatecrasher = Player.new("foo12")
        expect(game.players.include? gatecrasher).to eq false

        expect{game.skip(gatecrasher)}.to raise_error(NotPlayersTurnError)
      end
    end

    context "When a valid move is made..." do
      let(:game){ Uno::Game.new}

      before(:each) do
        game.add_player Player.new("Char")
        game.add_player Player.new("angelphish")

        game.start
      end

      context "If that was the player's last card" do
        before(:each) do
          expect(Rules).to receive(:card_can_be_played?).and_return(true)
          expect(game.current_player).to receive(:hand).at_least(:once).and_return([spy("Card")])

          game.play(game.current_player, game.current_player.hand.last)
        end

        it "The state is :game_over" do
          expect(game.state).to eq :game_over
        end

        it "No further moves are accepted" do
          expect{
            game.play(game.current_player, spy("Card"))
          }.to raise_error(GameIsOverError)
        end
      end

      context "If the player still has cards in their hand" do
        before(:each) do
          expect(Rules).to receive(:card_can_be_played?).and_return(true)

          game.current_player.put_card_in_hand Card.new(:two, :blue)
          game.current_player.put_card_in_hand Card.new(:red, :one)

          @played_card = game.current_player.hand.last
          @going_player = game.current_player

          game.play(game.current_player, @played_card)
        end

        it "The card that was just played is now on top of the discard pile" do
          expect(game.discard_pile.last).to eq @played_card
        end

        it "The card that was just played is no longer in the player's hand" do
          expect(game.current_player.hand).not_to include @played_card
        end

        it "Gameplay moves to the next player in the list" do
          previous_player_index = game.players.find_index(@going_player)
          expected_player_index = previous_player_index + 1 % game.players.length

          expect(game.current_player).to eq game.players[expected_player_index]
        end

        it "The state is still :waiting_for_player_to_move" do
          expect(game.state).to be :waiting_for_player_to_move
        end
      end
    end

    context "When an invalid move is made..." do
      let(:game){ Uno::Game.new}

      before(:each) do
        expect(Rules).to receive(:card_can_be_played?).and_return(false)
        expect_any_instance_of(Player).to receive(:has_card?).and_return(true)

        game.add_player Player.new("Char")
        game.add_player Player.new("angelphish")

        game.start
      end

      it "Does not remove the played card from the player's hand" do
        playing_player = game.current_player
        starting_hand = playing_player.hand.clone
        begin
          game.play(game.current_player, spy("Card"))
        rescue
        end

        expect(playing_player.hand).to eq starting_hand
      end

      it "Does not move to the next player" do
        playing_player = game.current_player
        begin
          game.play(game.current_player, spy("Card"))
        rescue
        end

        expect(game.current_player).to eq playing_player
      end

    end

    context "Action cards" do
      let(:game){ Uno::Game.new }

      describe "Reverse" do
        context "When there are 3 or more players" do
          before(:each) do
            expect(Rules).to receive(:card_can_be_played?).and_return(true)

            game.add_player spy("Player", name: "Char")
            game.add_player spy("Player", name: "angelphish")
            game.add_player spy("Player", name: "Wheeee")

            game.start
          end

          it "Switches the direction of the play order when played" do
            original_play_order = game.players.clone

            game.play(game.current_player, Card.new(:reverse, :red))

            expect(game.players).to eq original_play_order.reverse
          end
        end

        context "When there are only two players" do
          before(:each) do
            expect(Rules).to receive(:card_can_be_played?).and_return(true)

            game.add_player spy("Player", name: "Char")
            game.add_player spy("Player", name: "angelphish")

            game.start
          end

          it "Does not switch the direction of the play order when played" do
            original_play_order = game.players.clone

            game.play(game.current_player, Card.new(:reverse, :red))

            expect(game.players).to eq original_play_order
          end
        end
      end

      describe "Skip" do
        before(:each) do
          expect(Rules).to receive(:card_can_be_played?).and_return(true)

          game.add_player spy("Player", name: "Char")
          game.add_player spy("Player", name: "angelphish")

          game.start
        end


        it "Skips the next player in the play order" do
          current_player_index = game.players.find_index(game.current_player)
          next_player_index = current_player_index + 1 % game.players.length-1

          game.play(game.current_player, Card.new(:skip, :red))

          expect(game.current_player).to eq game.players[next_player_index]
        end
      end

      describe "Draw Two" do
        let(:fake_hand) {[Uno::Card.new(:draw_two, :red), Uno::Card.new(:one, :red)]}

        before(:each) do
          game.start
        end
      end
    end
  end
end