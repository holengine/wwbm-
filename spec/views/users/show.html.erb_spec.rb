require 'rails_helper'

RSpec.describe "users/show", type: :view do
  let(:user) { build_stubbed(:user, name: "User", balance: 1000) }

  before do
    assign(:user, user)
    assign(:games, [nil])

    allow(view).to receive(:current_user).and_return(user)

    stub_template "users/_game.html.erb" => "template game"

    render
  end

  it 'renders user name' do
    expect(rendered).to match 'User'
  end

  it 'renders button change password' do
    expect(rendered).to match link_to 'Сменить имя и пароль', edit_user_registration_path(user)
  end

  it 'renders games' do
    expect(rendered).to match 'template game'
  end
end
