class ColdCall < ApplicationRecord
  belongs_to :user
  belongs_to :course

  def self.random_student(course)
    mincount = ColdCall.where(course: course).minimum(:count).to_i
    cccount = ColdCall.where(course: course).count
    stdcount = course.students.count
    if cccount < stdcount
      # need to get a random student from course, not coldcall
      idset = ColdCall.where(course: course).pluck('user_id') 
      lucky = course.students.where.not(id: idset).shuffle()[0]
      cc = ColdCall.new(course: course, user: lucky, count: 1)
      cc.save
    else
      cc = ColdCall.where(course: course, count: mincount)
      lucky = User.find(cc.shuffle()[0].user_id)
      cc = ColdCall.where(course: course, user: lucky).first
      cc.count += 1
      cc.save
    end
    return lucky
  end

end
