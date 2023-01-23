require 'rails_helper'

RSpec.describe "games/game", type: :view do
  let(:game) { build_stubbed(:game, id: 15, created_at: Time.parse('2022.10.09, 10:00'), current_level: 10, prize: 1000) }

  before() do
    allow(game).to receive(:status).and_return(:in_progress)

    render partial: 'users/game', object: game
  end

  it 'renders game id' do
    expect(rendered).to match '15'
  end

  it 'renders game start time' do
    expect(rendered).to match '09 окт., 07:00'
  end

  it 'renders game current question' do
    expect(rendered).to match '10'
  end

  it 'renders game status' do
    expect(rendered).to match 'в процессе'
  end

  it 'renders game prize' do
    expect(rendered).to match '1 000 ₽'
  end
end