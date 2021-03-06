class Product < ActiveRecord::Base
  has_many :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  validates :title, :description, :image_url, presence: true
  validates :price, numericality: {greater_than_or_equal_to: 0.05}
  validates :title, uniqueness: true
  validates :image_url, allow_blank: true, format: {
      with: %r{\.(gif|jpe?g|png)\Z}i,
      message: 'must be a URL for GIF, JPG or PNG image.'
  }

  validate :validate_five_rappen

  def validate_five_rappen
    return unless self.price.present?
    return unless self.price*100 % 5 != 0
    errors.add(:price, "can only have .00 or .05 rappen")
  end

  def self.latest
    Product.order(:updated_at).last
  end


  private
    # ensure that there are no line items referencing this product
    def ensure_not_referenced_by_any_line_item
      if line_items.empty?
        return true
      else
        errors.add(:base, 'Line Items present')
        return false
      end
    end
end
