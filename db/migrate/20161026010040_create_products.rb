class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.integer :productid
      t.string :name
      t.string :um
      t.string :qum
      t.integer :qpu
			t.boolean :discontinued, default: false
      t.timestamps
    end
		add_index :products, :productid
  end
end
