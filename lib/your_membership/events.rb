module YourMembership
  # YourMembership Events Namespace
  class Events < YourMembership::Base
    # Returns a list of Community Events based on the supplied search term.
    #
    # @see https://api.yourmembership.com/reference/2_00/Events_All_Search.htm
    #
    # @param [YourMembership::Session] session
    # @param [Hash] options
    # @option options [String] :SearchText Text to be searched.
    # @option options [Integer] :PageSize The maximum number of records in the returned result set.
    # @option options [Integer] :StartRecord The record number at which to start the returned result set.
    # @return [Array] Returns an Array of Hashes representing events based on a search result.
    def self.all_search(session, options = {})
      # Options include :SearchText(String), :PageSize(Integer), :StartRecord(Integer)

      response = post('/', :body => build_XML_request('Events.All.Search', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Events.All.Search'], ['Results', 'Item']
    end

    # Returns a list of all Attendees for the specified event including both Registrations and RSVPs. If the Event
    # Registration contains a related Custom Form, the form data will be included in the <DataSet> element as it is
    # stored in our database. Records for authenticated members also include the <ID> element to cross reference the
    # Member's data.
    #
    # @see https://api.yourmembership.com/reference/2_00/Events_Event_Attendees_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [Integer] event_id An Event ID for which to return event details.
    # @return [Array] Returns an Array of Hashes representing the attendees to a specific event.
    def self.event_attendees_get(session, event_id)
      options = {}
      options[:EventID] = event_id

      response = post('/', :body => build_XML_request('Events.Event.Attendees.Get', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Events.Event.Attendees.Get'], ['Attendees', 'Attendee']
    end

    # Returns details about the provided Event ID.
    #
    # @see https://api.yourmembership.com/reference/2_00/Events_Event_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [Integer] event_id An Event ID for which to return event details.
    # @return [Hash] Returns a Hash of details about a particular event.
    def self.event_get(session, event_id)
      options = {}
      options[:EventID] = event_id

      response = post('/', :body => build_XML_request('Events.Event.Get', session, options))

      response_valid? response
      response['YourMembership_Response']['Events.Event.Get'].to_h
    end
  end
end
