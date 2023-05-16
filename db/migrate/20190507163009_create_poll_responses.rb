class CreatePollResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_responses do |t|
      t.references :user, foreign_key: true
      t.references :poll, foreign_key: true
      t.text :response
      t.string :type

      t.timestamps
    end
  end
end
