class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.text :note
      t.references :user, foreign_key: true
			t.string :name
			t.string :cuisine
      t.timestamps
    end
    add_index :orders, [:user_id, :created_at]
    add_index :orders, :created_at
  end
end
