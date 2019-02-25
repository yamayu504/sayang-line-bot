class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true
  def get_s3_image

  end
end
