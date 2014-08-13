module YourMembership
  module Sa
    # YourMembership System Administrator Commerce Namespace
    class Commerce < YourMembership::Base
      # Returns the order details, including line items and products ordered, of a store order.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Commerce_Store_Order_Get.htm
      #
      # @param [String] invoice_id The Invoice ID of the store order to be returned.
      # @return [Hash] Returns a Hash representing a store order
      def self.store_order_get(invoice_id)
        options = {}
        options[:InvoiceID] = invoice_id

        response = post('/', :body => build_XML_request('Sa.Commerce.Store.Order.Get', nil, options))

        response_valid? response
        response['YourMembership_Response']['Sa.Commerce.Store.Order.Get']
      end
    end
  end
end
