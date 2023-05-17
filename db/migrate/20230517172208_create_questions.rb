class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.text :qname
      t.text :answer
      t.string :type
      t.references :course

      t.timestamps
    end
  end
end
