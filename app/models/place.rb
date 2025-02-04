class Place < ApplicationRecord
  belongs_to :trip

  # ✅ Validations
  validates :name, presence: true
  validates :category, presence: true
  validates :latitude, :longitude, numericality: true, allow_nil: true
  validates :formatted_address, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # ✅ Set default values if missing
  before_validation :set_defaults

  private

  def set_defaults
    self.cost ||= 0.0  # Default to $0 if not provided by user or API
  end
end