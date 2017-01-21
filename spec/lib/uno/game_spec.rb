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
        expect(Deck).to receive(:standard_uno_deck).and_call_original
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

      it "Can't restart the game once it's already started" do
        game.start

        expect{game.start}.to raise_error(GameHasStartedError)
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
        allow(Rules).to receive(:card_can_be_played?).and_return(true)

        card_the_player_does_not_have = Uno::Card.new(:zero, :yellow)
        game.players[0].take_card_from_hand(card_the_player_does_not_have) if game.players[0].has_card?(card_the_player_does_not_have)

        expect{
          game.play(game.players[0], card_the_player_does_not_have)
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

      context "If the draw pile becomes empty" do
        before do
          expect(game.draw_pile).to receive(:empty?).and_return(true)
        end

        it "The discard pile is reshuffled and becomes the draw pile" do
          discard_pile_count = game.discard_pile.count
          game.skip(game.current_player)
          expect(game.draw_pile.count).to eq discard_pile_count - 1
        end

        it "Emits an event to let the outside world know this has happened" do
          expect(game).to receive(:notify_observers).with(:draw_pile_empty)
          game.skip(game.current_player)
        end
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

      it "A player cannot skip if the game is not in progress" do
        expect_any_instance_of(GameState).to receive(:game_in_progress?).and_return(false)
        expect{game.skip(game.current_player)}.to raise_error(GameHasNotStartedError)
      end

      it "A player cannot skip if the game is awaiting a wd4 response" do
        expect_any_instance_of(GameState).to receive(:is?).with(:awaiting_wd4_response).and_return(true)
        expect{game.skip(game.current_player)}.to raise_error(WaitingForWD4ResponseError)
      end
    end

    context "When a valid move is made..." do
      let(:game){Uno::Game.new}

      before(:each) do
        game.add_player Player.new("Char")
        game.add_player Player.new("angelphish")

        game.start
      end

      context "If that was the player's last card" do
        before(:each) do
          expect(Rules).to receive(:card_can_be_played?).and_return(true)
          expect(game.current_player).to receive(:hand).at_least(:once).and_return([spy("Card", :wild? => false)])

          game.play(game.current_player, game.current_player.hand.last)
        end

        it "The state is :game_over" do
          expect(game.state).to eq :game_over
        end

        it "No further moves are accepted" do
          expect{
            game.play(game.current_player, spy("Card", :wild? => false))
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
          game.play(game.current_player, spy("Card", :wild? => false))
        rescue
        end

        expect(playing_player.hand).to eq starting_hand
      end

      it "Does not move to the next player" do
        playing_player = game.current_player
        begin
          game.play(game.current_player, spy("Card", :wild? => false))
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

          it "Skips the next player in the play order" do
            original_player = game.current_player

            game.play(game.current_player, Card.new(:reverse, :red))

            expect(game.current_player).to eq original_player
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
          original_player = game.current_player

          game.play(game.current_player, Card.new(:skip, :red))

          expect(game.current_player).to eq original_player
        end
      end

      describe "Draw Two" do
        before(:each) do
          expect(Rules).to receive(:card_can_be_played?).and_return(true)

          game.add_player spy("Player", name: "Char", hand: [])
          game.add_player spy("Player", name: "angelphish", hand: [])

          game.start
        end

        it "Next player has to pick up two cards" do
          expect(game.next_player).to receive(:put_card_in_hand).twice

          game.play(game.current_player, Card.new(:draw_two, :red))
        end

        it "Skips the next player in the play order" do
          original_player = game.current_player

          game.play(game.current_player, Card.new(:draw_two, :red))

          expect(game.current_player).to eq original_player
        end
      end

      describe "Wild" do
        before(:each) do
          allow(Rules).to receive(:card_can_be_played?).and_return(true)

          game.add_player spy("Player", name: "Char", hand: [])
          game.add_player spy("Player", name: "angelphish", hand: [])

          game.start
        end

        context "When provided without a color choice" do
          it "Throws an error" do
            expect{game.play(game.current_player, Card.new(:wild))}.to raise_error(NoColorChosenError)
          end
        end

        context "When provided with a color choice that is not an uno card color" do
          it "Throws an error" do
            expect{game.play(game.current_player, Card.new(:wild), :butt)}.to raise_error(InvalidColorChoiceError)
          end
        end

        context "When provided with a valid color choice" do
          it "the next card on the discard pile has the color chosen" do
            played_card = Card.new(:wild)
            expect(game.current_player).to receive(:take_card_from_hand).and_return(played_card)
            game.play(game.current_player, played_card, :yellow)

            expect(game.discard_pile.last.color).to eq :yellow
          end
        end
      end

      describe "Wild Draw Four" do
        before(:each) do
          allow(Rules).to receive(:card_can_be_played?).and_return(true)

          fake_hand = spy("Hand", count: 5)
          game.add_player spy("Player", name: "Char", hand: fake_hand)
          game.add_player spy("Player", name: "angelphish", hand: fake_hand)

          game.start
        end

        context "When provided without a color choice" do
          it "Throws an error" do
            expect{game.play(game.current_player, Card.new(:wild_draw_four))}.to raise_error(NoColorChosenError)
          end
        end

        context "When provided with a color choice that is not an uno card color" do
          it "Throws an error" do
            expect{game.play(game.current_player, Card.new(:wild_draw_four), :butt)}.to raise_error(InvalidColorChoiceError)
          end
        end

        context "When provided with a valid color choice" do
          before(:each) do
            played_card = Card.new(:wild_draw_four)
            allow(game.current_player).to receive(:take_card_from_hand).and_return(played_card)
            game.play(game.current_player, played_card, :yellow)
          end

          it "The game state is :awaiting_wd4_response" do
            expect(game.state).to eq :awaiting_wd4_response
          end

          it "The game can't be restarted" do
            expect{game.start}.to raise_error(GameHasStartedError)
          end

          it "Normal moves can't be made" do
            expect{game.play(game.current_player, Card.new(:two, :yellow))}.to raise_error(WaitingForWD4ResponseError)
          end

          it "Players can't be added" do
            expect{game.add_player(Player.new("Gatecrasher"))}.to raise_error(GameHasStartedError)
          end

          it "Players can't be skip their turn" do
            expect{game.skip(game.current_player)}.to raise_error(WaitingForWD4ResponseError)
          end

          it "the next card on the discard pile has the color chosen" do

            expect(game.discard_pile.last.color).to eq :yellow
          end
        end
      end
    end

    describe "WD4 challenges" do
      before(:each) do
        allow(Rules).to receive(:card_can_be_played?).and_return(true)

        fake_hand = spy("Hand", count: 5)
        game.add_player spy("Player", name: "Char", hand: fake_hand)
        game.add_player spy("Player", name: "angelphish", hand: fake_hand)

        game.start
      end

      describe "#challenge(challenger)" do
        it "Throws an error if a WD4 challenge has not been issued" do
          expect_any_instance_of(GameState).to receive(:is?).with(:awaiting_wd4_response).and_return(false)
          expect{game.challenge(game.next_player)}.to raise_error(NoWD4ChallengeActiveError)
        end

        it "Throws an error if the challenger is not the next player" do
          expect_any_instance_of(GameState).to receive(:is?).with(:awaiting_wd4_response).and_return(true)
          expect{game.challenge(game.current_player)}.to raise_error(NotPlayersTurnError)
        end

        describe "When a challenge has been made at the right time" do
          before(:each) do
            expect_any_instance_of(GameState).to receive(:is?).with(:awaiting_wd4_response).and_return(true)
          end

          it "the game goes back to waiting for a player's move" do
            game.challenge(game.next_player)

            expect(game.state).to eq :waiting_for_player_to_move
          end

          describe "and the WD4 was played illegally" do
            before(:each) do
              expect(Rules).to receive(:wd4_was_played_legally?).and_return(false)
            end

            it "the current player has to pick up 4 cards" do
              expect(game.current_player).to receive(:put_card_in_hand).exactly(4).times
              game.challenge(game.next_player)
            end

            it "play moves to the next player" do
              challenger = game.next_player
              game.challenge(game.next_player)
              expect(game.current_player).to eq challenger
            end
          end

          describe "But the WD4 was played legally" do
            before(:each) do
              expect(Rules).to receive(:wd4_was_played_legally?).and_return(true)
            end

            it "the challenger has to pick up 6 cards" do
              expect(game.next_player).to receive(:put_card_in_hand).exactly(6).times
              game.challenge(game.next_player)
            end

            it "play stays on the same player" do
              current_player = game.current_player
              game.challenge(game.next_player)
              expect(game.current_player).to eq current_player
            end
          end
        end
      end

      describe "#accept(next_player)" do
        it "Throws an error if a WD4 challenge has not been issued" do
          expect_any_instance_of(GameState).to receive(:state).and_return(:waiting_for_player_to_move)
          expect{game.accept(game.next_player)}.to raise_error(NoWD4ChallengeActiveError)
        end

        it "Throws an error if the player accepting is not the next player" do
          expect_any_instance_of(GameState).to receive(:state).and_return(:awaiting_wd4_response)
          expect{game.accept(game.current_player)}.to raise_error(NotPlayersTurnError)
        end

        describe "When a move has been accepted at the right time" do
          before(:each) do
            expect_any_instance_of(GameState).to receive(:is?).with(:awaiting_wd4_response).and_return(true)
          end

          it "the game goes back to waiting for a player's move" do
            game.accept(game.next_player)
            expect(game.state).to eq :waiting_for_player_to_move
          end

          it "Next player has to pick up 4 cards from the discard pile" do
            expect(game.next_player).to receive(:put_card_in_hand).exactly(4).times
            game.accept(game.next_player)
          end
        end
      end
    end
  end
end