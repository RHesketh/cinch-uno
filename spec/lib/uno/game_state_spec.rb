require 'spec_helper'

module Uno
  describe GameState do
    let (:subject) { GameState.new }

    describe "#is?" do
      it "compares something to the internal game state" do
        subject.set(:game_over)

        expect(subject.is? :game_over).to eq true
        expect(subject.is? :test).to eq false
      end
    end

    describe "#state" do
      it { expect(subject.state).to eq nil }
    end

    describe "#set(symbol)" do
      context "When passed something that is not a symbol" do
        it "Raises an error" do
          expect {subject.set("test")}.to raise_error(TypeError)
          expect {subject.set(1)}.to raise_error(TypeError)
          expect {subject.set(false)}.to raise_error(TypeError)
        end
      end

      context "When passed a symbol" do
        context "that is not on the list of game states" do
          it "raises an error" do
            expect {subject.set(:go_time)}.to raise_error(ArgumentError)
          end
        end

        context "that is on the list of game states" do
          it "sets the state" do
            valid_state = subject.states[1]

            expect(subject.state).not_to eq valid_state # Safety check
            subject.set(valid_state)
            expect(subject.state).to eq valid_state # Safety check
          end
        end
      end
    end

    describe "#game_in_progress?" do
      it ":waiting_to_start returns false" do
        subject.set(:waiting_to_start)
        expect(subject.game_in_progress?).to eq false
      end

      it ":waiting_for_player_to_move returns true" do
        subject.set(:waiting_for_player_to_move)
        expect(subject.game_in_progress?).to eq true
      end

      it ":awaiting_wd4_response returns true" do
        subject.set(:awaiting_wd4_response)
        expect(subject.game_in_progress?).to eq true
      end

      it ":game_over returns false" do
        subject.set(:game_over)
        expect(subject.game_in_progress?).to eq false
      end
    end
  end
end