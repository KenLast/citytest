class CreateLineitems < ActiveRecord::Migration[5.0]
  def change
    create_table :lineitems do |t|
			t.integer :quantity
			t.string :selum
			t.references :product, foreign_key: true
			t.references :order, foreign_key: true
			t.timestamps
    end
		add_index :lineitems, [:order_id, :product_id]
  end
end
