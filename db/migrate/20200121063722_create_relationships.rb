class CreateRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # followed_idとfollower_idの組み合わせが単一であるように設定する
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
