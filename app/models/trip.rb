class Trip < ApplicationRecord
  belongs_to :user, optional: true  # ✅ Allows guest trips
  has_many :places, dependent: :destroy
  has_many :costs, dependent: :destroy

  # ✅ Ensures required fields
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :trip_length, numericality: { greater_than: 0 }, allow_nil: true
  validates :budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # ✅ Require `user_id` if the trip is being saved permanently
  validates :user_id, presence: true, unless: :is_guest_trip?

  # ✅ Set default values *before* validation
  before_validation :set_defaults, on: :create

  # ✅ Run defaults at object creation so budget is always set
  def initialize(attributes = {})
    super
    set_defaults  # ✅ Ensure defaults run when object is created
  end

  private

  def set_defaults
    self.start_date ||= Date.today
    self.trip_length ||= 7
    self.end_date ||= self.start_date + self.trip_length.days
    self.budget ||= self.trip_length * 200  # ✅ Ensures budget is always set
  end
end
