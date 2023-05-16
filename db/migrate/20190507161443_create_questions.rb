class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.text :qname
      t.text :qcontent 
      t.text :answer
      t.string :type
      t.string :content_type
      t.references :course, foreign_key: true

      t.timestamps
    end
  end
end
