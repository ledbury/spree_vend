shared_examples "receives a vend customer" do

  it "saves email to order" do
    expect(order.reload.email).not_to be_empty
  end

  it "creates user" do
    expect(User.find_by_email(order.email)).not_to be_nil
  end

  it "saves user to order" do
    expect(order.reload.user).not_to be_nil
  end

end
