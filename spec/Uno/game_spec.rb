require 'spec_helper'

module Uno
  describe Game do
    let(:fake_deck) {
      array = []
      20.times do
        array << Uno::Card.new
      end

      array
    }

    let(:game) { Uno::Game.new(deck: fake_deck) }

    it 'Starts in a :waiting_to_start state' do
      expect(game.state).to be :waiting_to_start
    end

    context "While waiting to start..." do
      it "Don't start the game unless there are at least 2 players" do
        expect{
          game.start
        }.to raise_error(Game::NotEnoughPlayers)
      end

      it "Allow multiple players to join the game" do
        game.add_player("Char")
        game.add_player("angelphish")

        expect(game.players).to be_a Hash

        expect(game.players.keys[0]).to eq "Char"
        expect(game.players.keys[1]).to eq "angelphish"

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
        }.to raise_error(Game::GameHasNotStarted)
      end
    end

    context "When the game is started with at least two players..." do
      let(:fake_players) { { "Char" => {}, "angelphish" => {} } }
      let(:game){ Uno::Game.new(players: fake_players)}

      it "Generate a deck to play with" do
        expect(Uno::Deck).to receive(:generate).and_call_original

        game.start
      end

      it "Shuffle the deck" do
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)

        expect(fake_deck).to receive(:shuffle!)

        new_game.start
      end

      it "Deals 7 cards to each player" do
        game.start

        game.players.each do |player, info|
          expect(info[:cards]).to be_an Array
          expect(info[:cards].length).to eq 7
        end
      end

      it "Place one card from the deck on the discard pile" do
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)
        new_game.start

        expect(new_game.discard_pile).to be_an Array
        expect(new_game.discard_pile.length).to eq 1
        expect(new_game.discard_pile.last).to be_a Uno::Card
      end

      it "Place the remaining cards from the deck into a draw pile" do
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)
        new_game.start

        expect(new_game.draw_pile).to be_an Array
        expect(new_game.draw_pile.length).to eq 5
        expect(new_game.draw_pile.last).to be_a Uno::Card
      end

      it "Determine a play order" do
        game.start

        expect(game.play_order).to be_an Array
        expect(game.play_order.length).to eq 2
      end

      it "Expose the current player's name" do
        game.start

        expect(game.current_player).to be_a String
        expect(fake_players.keys.include?(game.current_player)).to be true
      end

      it "Begin in a :waiting_for_player state" do 
        game.start
        expect(game.state).to be :waiting_for_player
      end

      xit "Can't add players once the game has started"
    end

    context "Move validation" do
      let(:fake_hand) {[Uno::Card.new(:one, :red), Uno::Card.new(:zero, :blue), Uno::Card.new(:two, :yellow)]}
      let(:fake_info) {{:cards => fake_hand}}
      let(:fake_players) { { "Char" => fake_info, "angelphish" => fake_info } }
      let(:game){ Uno::Game.new(players: fake_players)}

      before(:each) do 
        game.start(static_play_order: true, shuffle_deck: false)
      end

      it "Moves are only accepted from players who are in the game" do
        expect{
          game.play("foo12", Uno::Card.new)
        }.to raise_error(Game::NotPlayersTurn)
      end

      it "A player cannot move unless it is their turn" do
        expect(game.current_player).to eq "Char"

        expect{
          game.play("angelphish", Uno::Card.new)
        }.to raise_error(Game::NotPlayersTurn)
      end

      it "A player cannot play a card that is not in their hand" do
        expect{
          game.play("Char", Uno::Card.new(:zero, :yellow))
        }.to raise_error(Game::PlayerDoesNotHaveThatCard)
      end

      it "Valid move: Playing a card matching the color of the card on top of the discard pile" do
        expect(game.discard_pile.last.type).to eq :zero
        expect(game.discard_pile.last.color).to eq :red

        expect{
          game.play("Char", Uno::Card.new(:zero, :blue))
        }.not_to raise_error
      end

      it "Valid move: Playing a card matching the number of the card on top of the discard pile" do
        expect(game.discard_pile.last.type).to eq :zero
        expect(game.discard_pile.last.color).to eq :red

        expect{
          game.play("Char", Uno::Card.new(:one, :red))
        }.not_to raise_error
      end

      it "Invalid move: Playing a card that does not match the color or number of the card on top of the discard pile" do
        expect(game.discard_pile.last.type).to eq :zero
        expect(game.discard_pile.last.color).to eq :red

        expect{
          game.play("Char", Uno::Card.new(:two, :yellow))
        }.to raise_error(Game::InvalidMove)
      end
    end

    context "When a player skips instead of taking their turn" do
      let(:fake_players) { { "Char" => {}, "angelphish" => {} } }
      let(:game){ Uno::Game.new(players: fake_players)}

      before(:each) do 
        game.start(static_play_order: true, shuffle_deck: false)
      end

      it "Control goes to the next player" do
        current_player = game.play_order.find_index(game.current_player)
        next_player = current_player + 1 % game.players.length

        game.skip("Char")

        expect(game.current_player).to eq game.players.keys[next_player]
      end

      it "The skipping player picks up a card" do 
        skipping_player = "Char"
        number_of_cards_beforehand = game.players[skipping_player][:cards].length

        game.skip(skipping_player)

        expect(game.players[skipping_player][:cards].length).to be > number_of_cards_beforehand
      end

      it "A player cannot skip if it is not their turn" do
        expect(game.current_player).to eq "Char"

        expect{game.skip("angelphish")}.to raise_error(Game::NotPlayersTurn)
      end

      it "A player cannot skip if they are not playing" do
        expect(game.current_player).to eq "Char"

        expect{game.skip("foo12")}.to raise_error(Game::NotPlayersTurn)
      end
    end

    context "When a valid move is made..." do
      let(:fake_hand) {[Uno::Card.new(:one, :red), Uno::Card.new(:zero, :blue)]}
      let(:fake_info) {{:cards => fake_hand}}
      let(:going_player) { "Char"}
      let(:played_card) {fake_hand.first}
      let(:fake_players) { { "Char" => fake_info, "angelphish" => fake_info } }
      let(:game){ Uno::Game.new(players: fake_players)}

      before(:each) do
        game.start(static_play_order: true, shuffle_deck: false)
        game.play(going_player, played_card)
      end

      context "If that was the player's last card" do
        let(:fake_hand) {[Uno::Card.new(:one, :red)]}

        it "The state is :game_over" do
          expect(game.state).to be :game_over
        end

        it "No further moves are accepted" do
        expect{
          game.play("Char", Uno::Card.new(:two, :yellow))
        }.to raise_error(Game::GameIsOver)
        end
      end

      context "If the player still has cards in their hand" do
        it "The card that was just played is now on top of the discard pile" do
          expect(game.discard_pile.last.color).to eq :red
          expect(game.discard_pile.last.type).to  eq :one
        end

        it "The card that was just played is no longer in the player's hand" do
          game.players[game.current_player][:cards].any?{|c| c == played_card}
        end

       it "Gameplay moves to the next player in the list" do
        current_player = game.play_order.find_index(going_player)
        next_player = current_player + 1 % game.players.length

        expect(game.current_player).to eq game.players.keys[next_player]
       end

       it "The state is still :waiting_for_player" do 
        expect(game.state).to be :waiting_for_player
       end
      end
    end

    context "Action cards" do
      let(:fake_hand) {[Uno::Card.new(:one, :red), Uno::Card.new(:zero, :blue)]}
      let(:fake_info) {{:cards => fake_hand}}
      let(:going_player) { "Char"}
      let(:fake_players) { { "Char" => fake_info, "angelphish" => fake_info, "trich" => fake_info} }
      let(:game){ Uno::Game.new(players: fake_players)}


      describe "Skip" do
        let(:fake_hand) {[Uno::Card.new(:skip, :red), Uno::Card.new(:one, :red)]}

        before(:each) do
          game.start(static_play_order: true, shuffle_deck: false)
        end


        it "Skips the next player in the play order" do
          expect(game.current_player).to eq "Char"

          game.play(going_player, fake_hand.first)

          expect(game.current_player).to eq "trich"
        end
      end
    end
  end
end