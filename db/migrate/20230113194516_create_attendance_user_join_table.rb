class CreateAttendanceUserJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :attendances, :users do |t|
      # t.index [:attendance_id, :user_id]
      t.index [:user_id, :attendance_id], unique: true
    end
  end
end
