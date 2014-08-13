module YourMembership
  module Sa
    # YourMembership System Administrator Events Namespace
    class Events < YourMembership::Base
      # Returns a list of Events for the community optionally filtered by date or event name.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Events_All_GetIDs.htm
      #
      # @param [Hash] options
      # @option options [DateTime] :StartDate Starting date to filter the Event Start Date.
      # @option options [DateTime] :EndDate Ending date to filter the Event Start Date.
      # @option options [String] :Name Filter the returned events by Event Name.
      # @return [Array] Returns an Array of Event IDs
      def self.all_getIDs(options = {}) # rubocop:disable Style/MethodName
        response = post('/', :body => build_XML_request('Sa.Events.All.GetIDs', nil, options))

        response_valid? response
        if response['YourMembership_Response']['Sa.Events.All.GetIDs']
          response['YourMembership_Response']['Sa.Events.All.GetIDs']['EventID']
        else
          return[]
        end
      end

      # Returns Event Registration details for the provided Event and Event Registration ID. If the Event Registration
      # contains a related Custom Form, the form data will be included in the <DataSet> element as it is stored in our
      # database.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Events_Event_Registration_Get.htm
      #
      # @param [Integer] event_id The ID number for the Event from which you wish to retrieve the Event Registration.
      # @param [Hash] options Either RegistrationID or Badge Number are required.
      # @option options [String] :RegistrationID RegistrationID of the Registration data to return.
      # @option options [Integer] :BadgeNumber The Badge Number / Registration Number for an Event Registration record.
      # @return [Hash] Returns a Hash representing an event registration
      def self.event_registration_get(event_id, options = {})
        options[:EventID] = event_id

        response = post('/', :body => build_XML_request('Sa.Events.Event.Registration.Get', nil, options))

        response_valid? response
        response['YourMembership_Response']['Sa.Events.Event.Registration.Get']
      end

      # Returns a list of Registration IDs for the specified Event ID.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Events_Event_Registrations_GetIDs.htm
      #
      # @param [Integer] event_id The ID number for the Event from which you wish to retrieve the Event Registration.
      # @return [Array] Returns an Array of registration IDs for a specific event.
      def self.event_registrations_getIDs(event_id) # rubocop:disable Style/MethodName
        options = {}
        options[:EventID] = event_id

        response = post('/', :body => build_XML_request('Sa.Events.Event.Registrations.GetIDs', nil, options))

        response_valid? response
        if response['YourMembership_Response']['Sa.Events.Event.Registrations.GetIDs']
          response['YourMembership_Response']['Sa.Events.Event.Registrations.GetIDs']['RegistrationID']
        else
          return []
        end
      end
    end
  end
end
