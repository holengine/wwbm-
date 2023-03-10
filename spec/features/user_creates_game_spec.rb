require 'rails_helper'

RSpec.feature 'USER creates game', type: :feature do
  let(:user) { create :user }

  let!(:questions) do
    (0..14).to_a.map do |i|
      create(
      :question, level: i,
      text: "Когда была битва #{i}?",
      answer1: '1380', answer2: '1381', answer3: '1382', answer4: '1383'
      )
    end
  end

  before { login_as user }

  scenario 'success' do
    visit '/'

    click_link 'Новая игра'

    expect(page).to have_content('Когда была битва 0?')
    expect(page).to have_content('1380')
    expect(page).to have_content('1381')
    expect(page).to have_content('1382')
    expect(page).to have_content('1383')
  end
end