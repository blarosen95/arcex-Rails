class OrderBook
  def initialize(order)
    @order = order
    @order_book = nil
    @book_order = nil
  end

  #   def process_order(order)
  def call
    ActiveRecord::Base.transaction do
      set_order_book(10)

      if @order_book.present?
        @order_book.each do |matching_order|
          # First, attempt to lock the order:
          matching_order.with_lock! do |locked_order|
            # With the current iteration's order locked, first call our match validator method:
            validate_order_match!(locked_order)

            # If we're here, then the order past protective measures, and we continue to match the two orders together:
            # But first, we should assign the book_order to our instance variable:
            @book_order = locked_order

            match_order!

            # After having matched the two orders, we should cleanup the locked book order:
            @book_order.update!(locked: false)
          end

          # If the current order is fully filled, we should break out of the loop and stop processing any further:
          break if @order.fully_filled?
        end

        # If the order book is exhausted, and current order is neither fully filled nor a market order, we should ensure the current order will queue in future order book creations:
        unless @order.market_order? || @order.fully_filled?
          @order.update!(status: :processing,
                         locked: false)
        end
      else
        # TODO: In this case, we should prepare and queue if limit order. Otherwise, cancel as a failed market order
        puts "filter here: UH OH!! Didn't manage to instantiate a matching order book for #{@order.id}"

        # TODO: Replace with sufficent cleanup:
        return if @order.market_order?

        @order.update!(status: :processing, locked: false)
      end
    end
  end

  private

  def execution_price
    # Since we pre-validate price constraints before this is used, we can always use the book order's potentially better (otherwise equal) price:
    @book_order.price
  end

  def execution_amount
    # We should always execute the lesser of the two orders' remaining amounts:
    # [@book_order.amount_remaining, @order.amount_remaining].min
    rtn = [@book_order.amount_remaining, @order.amount_remaining].max
    puts "filter here: upstream... executing on #{rtn}"
    [@book_order.amount_remaining, @order.amount_remaining].min
  end

  # TODO: Likely need to optimize and paginate this method:
  def set_order_book(num_orders = 1)
    price_order = @order.buy? ? :asc : :desc

    @order_book = Order.where(asset: @order.asset, direction: @order.opposite_direction,
                              status: :processing, locked: false, order_type: :limit_order)
                       .where.not(user_id: @order.user_id).order(price: price_order, created_at: :asc).limit(num_orders)
  end

  def validate_order_match!(book_order)
    # We don't price check when processing market orders:
    return if @order.market_order?

    # Raise/Throw an error if the book_order is too low/high for the current order based on direction:
    return if @order.direction == 'buy' && book_order.price <= @order.price
    return if @order.direction == 'sell' && book_order.price >= @order.price

    # At this point, the order (and theoretically, all of the order book's contents) are invalid for the current order:
    # We should terminate the service's execution at this point and add whatever remains to be filled to the order book
    puts "filter here: Order #{book_order.id} is invalid for order #{@order}"
    # TODO: Should we raise an error to terminate? Revisit, implement limit order queuing around this point in code path
    # TODO: For right now, to ensure this method prevents further execution, we'll raise an error:
    raise StandardError, "filter here: Order #{book_order.id} is invalid for order #{@order}"
  end

  def match_order!
    # First, we should try to create the trade object:
    trade = Trade.new(immediate_order: @order, book_order: @book_order, execution_price:,
                      execution_amount:)

    # If the trade object is valid:
    if trade.valid?
      # Execute the trade:
      trade.execute_trade!

      # If we're here, the trade was successful, and we should update the two orders:
      # TODO: I don't think that I will need to reassign the @order instance variable since it's most likely a reference to the changed object. Revisit if issues:
      @order.update!(
        amount_remaining: @order.amount_remaining - trade.execution_amount
      )

      # TODO: Will this work?? Remember that we have the book_order pessimistically locked from the block that called this method:
      # We should also update the book_order:
      @book_order.update!(
        amount_remaining: @book_order.amount_remaining - trade.execution_amount
      )

      @order.update_status_after_trade!
      @book_order.update_status_after_trade!
    else
      # TODO: If the trade object is invalid, we should ????:
      puts "filter here: Trade object is invalid for order #{@order}. It is invalid because: #{trade.errors.full_messages.join(', ')}"
    end
  end
end
