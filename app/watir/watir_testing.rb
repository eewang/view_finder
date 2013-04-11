# FRONT-END TEST

# => Sign-up
# => Login
  # => Existing user
    # => No password
  # => Attempted login by non-existing user
# => Instagram auth
  # => 
# => Gameplay
  # => New guess
  # => Attempted guess on already guessed photo


class WatirTesting
  attr_accessor :test_password

  def initialize
    @b = Watir::Browser.new
  end

  # def browser
  #   Watir::Browser.new
  # end

  def browser
    @b
  end

  def path
    self.browser.goto("http://localhost:3000") # Replace with root_path
  end

  # REGISTRATION/LOGIN TESTING

  def link(options)
    self.browser.link(options).click
  end

  def email
    self.browser.text_field(:id => "email").set("Watir Test #{rand(100)}")
  end

  def password
    @test_password = SecureRandom.hex(3)
    self.browser.text_field(:id => "password").set(@test_password)
  end

end