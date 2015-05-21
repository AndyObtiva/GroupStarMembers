class ApplicationSetting < ActiveRecord::Base
  validates :name, uniqueness: true
end
