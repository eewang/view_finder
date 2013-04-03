class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation

  validates_confirmation_of :email, :password
  validates_presence_of :email, :password

  has_many :authentications

  has_many :photos

  has_many :guesses
  has_many :photos, :through => :guesses

  has_many :identities

  has_secure_password

# provider, uid, oauth_token # => add to database migration

  def has_identity?(provider)
    Identity.find_by_provider_and_user_id(provider, self.id) ? true : false
  end

end
