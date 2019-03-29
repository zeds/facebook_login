class AddPostIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :post_id, :string
  end
end
