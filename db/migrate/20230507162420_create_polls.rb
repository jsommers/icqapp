class CreatePolls < ActiveRecord::Migration[5.2]
  def change
    create_table :polls do |t|
      t.boolean :isopen
      t.integer :round
      t.string :type
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
