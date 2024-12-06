class CreateUsers
  def change
    SeedBuilderUser.find_or_create_by(email: "test@example.com")
  end
end
