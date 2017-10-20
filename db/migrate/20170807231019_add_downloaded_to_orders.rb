class AddDownloadedToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :downloaded, :datetime
  end
end
