require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, is_admin: true ) }
  let(:game_w_questions) { create(:game_with_questions, user: user) }
  let(:game) { assigns(:game) }

  context 'anon user' do
    describe '#show' do
      before { get :show, params: {id: game_w_questions.id} }

      it 'response status not eq 200' do
        expect(response.status).not_to eq 200
      end

      it 'response redirect to new_user_session_path' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'displayed flash alert' do
        expect(flash[:alert]).to be
      end
    end
  end

  context 'auth user' do
    before { sign_in user }

    describe "#create" do
      before { generate_questions(60) }
      before { post :create }

      it 'game not finished' do
        expect(game.finished?).to be_falsey
      end

      it 'game belongs to the current user' do
        expect(game.user).to eq(user)
      end

      it 'response redirect to game_path' do
        expect(response).to redirect_to game_path(game)
      end

      it 'displayed notice alert' do
        expect(flash[:notice]).to be
      end
    end

    describe '#show' do
      before { get :show, params: {id: game_w_questions.id} }

      it 'game not finished' do
        expect(game.finished?).to be_falsey
      end

      it 'game belongs to the current user' do
        expect(game.user).to eq(user)
      end

      it 'response status eq 200' do
        expect(response.status).to eq(200)
      end

      it 'render template show' do
        expect(response).to render_template('show')
      end
    end

    describe '#answer' do
      before { put :answer, params: {id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key} }

      it 'game not finished' do
        expect(game.finished?).to be_falsey
      end

      it 'current level > 0' do
        expect(game.current_level).to be > 0
      end

      it 'response redirect to game_path' do
        expect(response).to redirect_to(game_path)
      end

      it 'not displayed alert' do
        expect(flash.empty?).to be_truthy
      end

    end
  end
end
