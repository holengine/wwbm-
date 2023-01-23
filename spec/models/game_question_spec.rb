require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) { create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  describe "#level" do
    it "correct question level" do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe "#text" do
    it "correct question text" do
      expect(game_question.text).to eq(game_question.question.text)
    end
  end

  describe "#variants" do
    it "correct variants" do
      expect(game_question.variants).to eq({ "a" => game_question.question.answer2,
                                             "b" => game_question.question.answer1,
                                             "c" => game_question.question.answer4,
                                             "d" => game_question.question.answer3
                                           })
    end
  end

  describe "#answer_correct?" do
    it "true" do
      expect(game_question.answer_correct?("b")).to be_truthy
    end
  end

  describe "#correct_answer_key" do
    it "correct answer key" do
      expect(game_question.correct_answer_key).to eq("b")
    end
  end

  describe "#help_hash" do
    before { game_question.help_hash[:key] = "test" }

    it "adds key to help hash" do
      expect(game_question.help_hash).to include(:key) and eq("test")
    end

    it "loads saved help hash from db" do
      game_question.save
      loaded_game_question = GameQuestion.find(game_question.id)

      expect(loaded_game_question.help_hash).to eq({ key: "test" })
    end
  end

  describe '#apply_help!' do
    context 'correct fifty_fifty' do
      context 'there is no desired key' do
        it 'help_hash not include fifty_fifty' do
          expect(game_question.help_hash).not_to include(:fifty_fifty)
        end
      end

      context 'there is the right key' do
        before { game_question.apply_help!(:fifty_fifty) }

        it 'help_hash include fifty_fifty' do
          expect(game_question.help_hash).to include(:fifty_fifty)
        end

        it 'there is a correct answer' do
          expect(game_question.help_hash[:fifty_fifty]).to include('b')
        end

        it 'there is a two variants' do
          expect(game_question.help_hash[:fifty_fifty].size).to eq(2)
        end
      end
    end

    context 'correct friend_call' do
      context 'there is no desired key' do
        it 'help_hash not include friend_call' do
          expect(game_question.help_hash).not_to include(:friend_call)
        end
      end

      context 'there is the right key' do
        before { game_question.apply_help!(:friend_call) }

        it 'help_hash include friend_call' do
          expect(game_question.help_hash).to include(:friend_call)
        end

        it 'correct display' do
          expect(game_question.help_hash[:friend_call]).to include('считает, что это вариант')
        end
      end
    end
  end
end
