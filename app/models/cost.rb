class Cost < ApplicationRecord
  belongs_to :trip

  # Cost categories
  enum :category, {
    transportation: 0,
    lodging: 1,
    dining: 2,
    attractions: 3,
    other: 4
  }, prefix: true

  # Validations
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
