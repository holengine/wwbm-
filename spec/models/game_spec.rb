require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { create(:user) }
  let(:game_w_questions) { create(:game_with_questions, user: user) }

  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      generate_questions(60)

      game = nil

      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(
        change(GameQuestion, :count).by(15).and(
          change(Question, :count).by(0)
        )
      )

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    it 'answer correct continues game' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)

      expect(game_w_questions.current_game_question).not_to eq(q)

      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    it 'correct .take_money!' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize).to be > 0

      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end
  end

  context '.status' do
    before do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max+1
      expect(game_w_questions.status).to eq(:won)
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end
  
  describe '#current_game_question' do
    it 'question is correctly displayed' do
      expect(game_w_questions.current_game_question).to eq(game_w_questions.game_questions[0])
    end
  end

  describe '#previous_level' do
    it 'previous level is correctly displayed' do
      expect(game_w_questions.previous_level).to eq(-1)
    end
  end

  describe '#answer_current_question' do
    let(:question) { game_w_questions.current_game_question }
    let(:correct_answer_is_given) { game_w_questions.answer_current_question!(question.correct_answer_key) }
    let(:wrong_answer_is_given) { game_w_questions.answer_current_question!('x') }

    context 'right answer' do
      it 'game continues' do
        correct_answer_is_given

        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.current_level).to eq(1)
      end

      it 'game is won' do
        game_w_questions.current_level = 14

        correct_answer_is_given

        expect(game_w_questions.status).to eq(:won)
        expect(game_w_questions.prize).to eq(Game::PRIZES.last)
        expect(game_w_questions.finished?).to be_truthy
      end

      it 'time has ended' do
        game_w_questions.created_at -= Game::TIME_LIMIT

        correct_answer_is_given

        expect(game_w_questions.status).to eq(:timeout)
        expect(game_w_questions.finished?).to be_truthy
      end
    end

    context 'wrong answer' do
      it 'game finished' do
        wrong_answer_is_given

        expect(game_w_questions.status).to eq(:fail)
        expect(game_w_questions.finished?).to be_truthy
      end

      it 'time has ended' do
        game_w_questions.created_at -= Game::TIME_LIMIT

        wrong_answer_is_given

        expect(game_w_questions.status).to eq(:timeout)
        expect(game_w_questions.finished?).to be_truthy
      end
    end
  end
end
