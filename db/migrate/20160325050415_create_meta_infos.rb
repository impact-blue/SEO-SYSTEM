class CreateMetaInfos < ActiveRecord::Migration
  def change
    create_table :meta_infos do |t|
      t.string :search_word
      t.text   :link_address
      t.string :link_text
      t.text :title
      t.text :description
      t.text :keywords
      t.text :h1
      t.string :search_engin
      t.string :error_page

      t.timestamps null: false
    end
  end
end
