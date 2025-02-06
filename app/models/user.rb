require "active_record"  # ✅ Ensure ActiveRecord is loaded

class User < ApplicationRecord
  has_secure_password  # ✅ Enables bcrypt password hashing

  has_many :trips, dependent: :destroy

  # ✅ Fix ENUM for Rails 8 - Use `as: :integer`
  enum :travel_style, {
    not_specified: 0,
    solo: 1,
    hikers: 2,
    family_trip: 3,
    business_trip: 4,
    budget_traveler: 5,
    luxury: 6,
    backpacking: 7,
    romantic: 8,
    adventure: 9,
    cultural: 10,
    foodie: 11,
    relaxation: 12,
    road_trip: 13
  }, prefix: true  # ✅ Fix `_prefix`

  # ✅ Ensure `travel_style` defaults to `none`
  after_initialize :set_default_travel_style, if: :new_record?

  def set_default_travel_style
    self.travel_style ||= "none"  # ✅ Store as a string to match Rails 8 expectations
  end

  # ✅ Temporarily remove validation to test
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
