class FgaInternshipPlugin::TaskItem < ActiveRecord::Base
  attr_accessible :description, :status, :file_path

  belongs_to :task_list
  has_many :submissions
end
