class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.boolean :admin
			t.string :customerid
			t.string :password_digest
			t.string :remember_digest
			t.string :activation_digest
			t.boolean :activated, default: false
			t.datetime :activated_at
			t.string	:reset_digest
			t.datetime :reset_sent_at
			t.string :cuisine
      t.timestamps
    end
		add_index :users, :email
		add_index :users, :customerid, unique: true
	end
end
