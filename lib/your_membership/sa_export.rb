module YourMembership
  module Sa
    # The Export object provides a convenient abstraction that encapsulates the export process
    #
    # @attr_reader [String] export_id The unique ID assigned by the API when an export is initiated
    # @attr_reader [Symbol] status The status of the current export request
    # @attr_reader [String] export_uri The uri from which to download the requested report once the status is :complete
    class Export < YourMembership::Base
      attr_reader :export_id, :status, :export_uri

      # Export Initializer - Use any of the public class methods to create objects of this type.
      #
      # @note There is not yet a compelling reason to call Export.new() directly, however it can be done.
      #
      # @param [String] export_id The ID of the export job for which to create the object.
      def initialize(export_id)
        @export_id = export_id
        @status = nil
        @export_uri = nil
      end

      # Instance implementation of the Sa::Export.status method that also sets the export_uri if the status is :complete
      # @return [Symbol] Returns the symbol for the current status state.
      def status
        unless @status == :complete || @status == :error || @status == :failure
          status_response = self.class.status(@export_id)
          @status = convert_status(status_response['Status'])
          update_export_uri(status_response) if @status == :complete
        end
        @status
      end

      # Returns the status of an export by ExportID. This method should be called until a status of either
      # FAILURE or COMPLETE is returned.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Status.htm
      #
      # @param [String] export_id ID of the Export on which to check status.
      # @return [Hash] Returns a hash with the status code for the current export as well as the URI of the exported
      #  data if available
      def self.status(export_id)
        options = {}
        options[:ExportID] = export_id

        response = post('/', :body => build_XML_request('Sa.Export.Status', nil, options))

        response_valid? response
        response['YourMembership_Response']['Sa.Export.Status']
      end

      # Starts an export of all invoice items.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_All_InvoiceItems.htm
      #
      # @param [DateTime] date Date to export records from.
      # @param [Boolean] unicode Export format.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.all_invoiceItems(date, unicode) # rubocop:disable Style/MethodName
        generic_export('Sa.Export.All.InvoiceItems', date, unicode)
      end

      # Starts an export of career openings.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Career_Openings.htm
      #
      # @param [DateTime] date Date to export records from.
      # @param [Boolean] unicode Export format.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.career_openings(date, unicode)
        generic_export('Sa.Export.Career.Openings', date, unicode)
      end

      # Starts an export of donation transactions.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Donations_Transactions.htm
      #
      # @param [DateTime] date Date to export records from.
      # @param [Boolean] unicode Export format.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.donations_transactions(date, unicode)
        generic_export('Sa.Export.Donations.Transactions', date, unicode)
      end

      # Starts an export of donation invoice items.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Donations_InvoiceItems.htm
      #
      # @param [DateTime] date Date to export records from.
      # @param [Boolean] unicode Export format.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.donations_invoiceItems(date, unicode) # rubocop:disable Style/MethodName
        generic_export('Sa.Export.Donations.InvoiceItems', date, unicode)
      end

      # Starts an export of dues transactions.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Dues_Transactions.htm
      #
      # @param [DateTime] date Date to export records from.
      # @param [Boolean] unicode Export format.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.dues_transactions(date, unicode)
        generic_export('Sa.Export.Dues.Transactions', date, unicode)
      end

      # Starts an export of dues invoice items.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Dues_InvoiceItems.htm
      #
      # @param [DateTime] date Date to export records from.
      # @param [Boolean] unicode Export format.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.dues_invoiceItems(date, unicode)  # rubocop:disable Style/MethodName
        generic_export('Sa.Export.Dues.InvoiceItems', date, unicode)
      end

      # Starts an export of store orders.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Store_Orders.htm
      #
      # @param [DateTime] date Date to export records from.
      # @param [Boolean] unicode Export format.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.store_orders(date, unicode)
        generic_export('Sa.Export.Store.Orders', date, unicode)
      end

      # Starts an export of store order invoice items.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Store_InvoiceItems.htm
      #
      # @param [DateTime] date Date to export records from.
      # @param [Boolean] unicode Export format.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.store_invoiceItems(date, unicode) # rubocop:disable Style/MethodName
        generic_export('Sa.Export.Store.InvoiceItems', date, unicode)
      end

      # Starts an export of registration records for an event
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Event_Registrations.htm
      #
      # @param [Integer] event_id Event ID of the event to view registrations.
      # @param [Boolean] unicode Export format.
      # @param [Hash] options
      # @option options [String] :SessionIDs Comma Delimited List of Session IDs to filter the results. ex: "1234,9876"
      # @option options [Integer] :ProductID Filter the results to only those that have purchased supplied Product ID.
      # @option options [Integer] :Processed Filter the results by their Process Status.
      #  Options: 0 = All, 1 = Open Records, 2 = Processed Records
      # @option options [String] :LastName Filter registrations by the supplied Last Name.
      # @option options [Boolean] :AttendedEvent Filter registrations check in status.
      # @return [YourMembership::Sa::Export] Returns an Export object that can be queried for status and the export data
      def self.event_registrations(event_id, unicode, options = {})  # rubocop:disable Style/MethodName
        options[:EventID] = event_id
        generic_export('Sa.Export.Event.Registrations', nil, unicode, options)
      end

      private

      def self.generic_export(api_method, date, unicode, options = {})
        options[:Unicode] = unicode
        options[:Date] = date

        response = post('/', :body => build_XML_request(api_method, nil, options))
        response_valid? response
        new(response['YourMembership_Response'][api_method]['ExportID'])
      end

      def update_export_uri(status_response)
        @export_uri = status_response['ExportURI']
      end

      # Convert YourMembership API codes to readable symbols
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Export_Status.htm
      #
      # @param [Integer] status The status code
      # @return [Symbol] The status as a Symbol
      def convert_status(status)
        case status
        when '-1'
          return :failure
        when '0'
          return :unknown
        when '1'
          return :working
        when '2'
          return :complete
        else
          return :error
        end
      end
    end
  end
end
