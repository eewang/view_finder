class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation

  validates_confirmation_of :email, :password
  validates_presence_of :email, :password

  has_secure_password

end
