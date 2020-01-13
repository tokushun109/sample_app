class AddAdminToUsers < ActiveRecord::Migration[5.2]
  def change
    # デフォルトで管理者になれないようにfalseを返すようにする
    add_column :users, :admin, :boolean, default: false
  end
end
