class CreateMetaInfos < ActiveRecord::Migration
  def change
    create_table :meta_infos do |t|
      t.string :search_word
      t.text :link_address
      t.string :link_text
      t.string :title
      t.string :description
      t.string :keywords

      t.timestamps null: false
    end
  end
end
