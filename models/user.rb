require 'digest/sha2'
class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation

  validates :email,
    presence: {},
    uniqueness: { case_sensitive: false },
    format: { allow_blank: true, on: :create, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  validates :password,
    presence: { on: :create },
    confirmation: {},
    length: { allow_blank: true, within: 6..20 }

  def self.encrypt_password(string)
    return Digest::SHA256.hexdigest(string)
  end

  before_create do
    self.encrypted_password = self.class.encrypt_password(self.password)
  end

end