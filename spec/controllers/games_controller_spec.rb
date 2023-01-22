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
      before() do
        generate_questions(60)
        post :create
      end

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

    context 'is trying to create a second game' do
      let!(:unfinished_game) { game_w_questions }
      subject { post :create }

      it 'game not finished' do
        expect(unfinished_game.finished?).to be_falsey
      end

      it "doesn't change games count" do
        subject
        expect { post :create }.to change(Game, :count).by(0)
      end

      it 'new game was not created' do
        subject
        expect(game).to be_nil
      end

      it 'response redirect to root_path' do
        subject
        expect(response).to redirect_to(game_path(unfinished_game))
      end

      it 'displayed flash alert' do
        subject
        expect(flash[:alert]).to be
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

    describe '#takemoney' do
      before() do
        game_w_questions.update_attribute(:current_level, 2)
        put :take_money, params: {id: game_w_questions.id}
      end

      it 'game finished' do
        expect(game.finished?).to be_truthy
      end

      it 'prize eq 200' do
        expect(game.prize).to eq(200)
      end

      it 'user balance eq 200' do
        user.reload
        expect(user.balance).to eq(200)
      end

      it 'response status eq 302' do
        expect(response.status).to eq(302)
      end

      it 'response redirect to user_path' do
        expect(response).to redirect_to(user_path(user))
      end

      it 'displayed warning alert' do
        expect(flash[:warning]).to be
      end
    end
  end

  context 'another auth user' do
    let(:another_user) { create(:user) }
    before { sign_in another_user }

    describe '#show alien game' do
      before { get :show, params: {id: game_w_questions.id} }

      it 'response status not eq 200' do
        expect(response.status).not_to eq 200
      end

      it 'response redirect to root_path' do
        expect(response).to redirect_to(root_path)
      end

      it 'displayed flash alert' do
        expect(flash[:alert]).to be
      end
    end
  end
end
