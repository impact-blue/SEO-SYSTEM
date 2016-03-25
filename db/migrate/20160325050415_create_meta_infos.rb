class CreateMetaInfos < ActiveRecord::Migration
  def change
    create_table :meta_infos do |t|
      t.string :search_word
      t.string :link_address
      t.string :link_text
      t.string :title
      t.string :discription
      t.string :keyword

      t.timestamps null: false
    end
  end
end
