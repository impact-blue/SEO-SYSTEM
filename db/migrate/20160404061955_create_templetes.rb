class CreateTempletes < ActiveRecord::Migration
  def change
    create_table :templetes do |t|
      t.string :search_word
      t.text   :link_address


      t.timestamps null: false
    end
  end
end
