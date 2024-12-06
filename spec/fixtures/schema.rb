ActiveRecord::Schema.define(version: 2024_12_06_200411) do
  create_table :seed_builder_users, force: true do |t|
    t.string :email
  end

  create_table :seed_users, force: true do |t|
    t.string :email
  end
end
