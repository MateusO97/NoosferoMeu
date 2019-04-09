class FgaInternshipPlugin::TaskList < ActiveRecord::Base
  attr_accessible :name, :link

  has_many :task_items
  has_many :submissions, through: :task_items
  
end
