require 'rails_helper'

RSpec.describe "users/index", type: :view do
  before() do
    assign(:users, [
      build_stubbed(:user, name: "Вадим", balance: 5000),
      build_stubbed(:user, name: "Михаил", balance: 3000)
    ])

    render
  end

  it "renders players names" do
    expect(rendered).to match("Вадим")
    expect(rendered).to match("Михаил")
  end

  it "render players balances" do
    expect(rendered).to match("5 000 ₽")
    expect(rendered).to match("3 000 ₽")
  end

  it "render players in names right order" do
    expect(rendered).to match(/Вадим.*Михаил/m)
  end
end