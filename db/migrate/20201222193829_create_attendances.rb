class CreateAttendances < ActiveRecord::Migration[6.0]
  def change
    create_table :attendances do |t|
      t.boolean :active
      t.references :course, foreign_key: true

      t.timestamps
    end
  end
end
