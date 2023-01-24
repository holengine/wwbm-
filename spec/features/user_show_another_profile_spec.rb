require 'rails_helper'

RSpec.feature 'USER show another user profile', type: :feature do
  let(:user) { create :user, name: 'Пользователь №1' }
  let(:another_user) { create :user, name: 'Пользователь №2' }

  let!(:games) {[
    create(
      :game,
      user_id: user.id,
      created_at: Time.parse('2023-01-23, 14:00 UTC'),
      current_level: 3904,
      prize: 55
    ),
    create(
      :game,
      user_id: user.id,
      created_at: Time.parse('2023-01-23, 13:00 UTC'),
      finished_at: Time.parse('2023-01-23, 13:10 UTC'),
      is_failed: true,
      current_level: 22232,
      prize: 1000
    )
  ]}

  before { login_as another_user }

  scenario 'success' do
    visit '/'

    click_link 'Пользователь №1'

    expect(page).to have_content('Пользователь №1')

    expect(page).to have_content('в процессе')
    expect(page).to have_content('проигрыш')

    expect(page).to have_content('3904')
    expect(page).to have_content('22232')

    expect(page).to have_content('23 янв., 14:00')
    expect(page).to have_content('23 янв., 13:00')

    expect(page).to have_content('55 ₽')
    expect(page).to have_content('1 000 ₽')

    expect(page).to have_content('50/50')
    expect(page).to have_selector('i', class: 'bi bi-telephone')
    expect(page).to have_selector('i', class: 'bi bi-people')

    expect(page).not_to have_content('Сменить имя и пароль')
  end
end