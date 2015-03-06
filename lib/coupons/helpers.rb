module Coupons
  # Define helpers for creating, applying and redeeming coupon codes.s
  # Create an object that extends from `Coupons::Helpers`, like the following:
  #
  #     Coupon = Object.new.extend(Coupons:Helpers)
  #     coupon = Coupon.create(amount: 10, type: 'percentage', redemption_limit: 100)
  #     #=> <Coupons::Models::Coupon instance>
  #
  #     # Apply the coupon code we created above to $42.
  #     Coupon.apply(coupon.code, amount: 42)
  #     #=> {amount: 42, discount: 10, total: 32}
  #
  #    # It creates a redemption entry for this coupon.
  #    Coupon.redeem(coupon.code, amount: 42)
  #    #=> {amount: 42, discount: 10, total: 32}
  #
  module Helpers
    # Redeem coupon code.
    # The `options` must include an amount.
    # If the coupon is still good, it creates a
    # `Coupons::Models::CouponRedemption` record, updating the hash with the
    # discount value, total value with discount applied.
    # It returns discount as `0` for invalid coupons.
    #
    #     redeem('ABC123', amount: 100)
    #     #=> {amount: 100, discount: 30, total: 70}
    #
    def redeem(code, options = {})
      options[:discount] = 0
      options[:total] = options[:amount]

      coupon = find_valid_by_code(code)
      return options unless coupon

      coupon.redemptions.create!(options.slice(:user_id, :order_id))
      coupon.apply(options)
    end

    # Apply coupon code.
    # If the coupon is still good, returns a hash containing the discount value,
    # and total value with discount applied. It doesn't redeem coupon.
    # It returns discount as `0` for invalid coupons.
    #
    #     apply_coupon('ABC123', amount: 100)
    #     #=> {amount: 100, discount: 30, total: 70}
    #
    def apply(code, options = {})
      options[:discount] = 0
      options[:total] = options[:amount]

      coupon = find_valid_by_code(code)
      return options unless coupon

      coupon.apply(options)
    end

    # Create a new coupon code.
    def create(options = {})
      Models::Coupon.create!(options)
    end

    # Find a coupon by its code.
    # It take expiration date or redemption count into consideration.
    def find_by_code(code)
      Models::Coupon.find_by_code(code)
    end

    # Find a valid coupon by its code.
    def find_valid_by_code(code)
      coupon = find_by_code(code)
      coupon.try(:redeemable?) && coupon
    end
  end
end