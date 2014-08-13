module YourMembership
  # The Commerce Namespace does not currently have any methods in the
  # YourMembership.com API. This is used for some helper methods.
  class Commerce
    # Converts some convenient Symbols to the Integer that the YourMembership API expects
    # @param [Symbol] status Accepts :cancelled, :open, :processed, :shipped
    # @return [Integer] Returns the integer that the API expects
    def self.convert_order_status(status)
      status_code = 0
      case status
      when :cancelled, :Cancelled
        status_code = -1
      when :open, :Open
        status_code = 0
      when :processed, :Processed
        status_code = 1
      when :shipped, :Shipped, :closed, :Closed
        status_code = 2
      else
        status_code = status
      end
      status_code
    end
  end
end
