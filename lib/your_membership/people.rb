module YourMembership
  # YourMembership People Namespace
  class People < YourMembership::Base
    # Returns paged results for a search request. Returns a maximum of 100 records per request.
    #
    # @see https://api.yourmembership.com/reference/2_00/People_All_Search.htm
    #
    # @param [YourMembership::Session] session
    # @param [Hash] options
    # @option options [String] :SearchText Text to be searched
    # @option options [Integer] :PageSize The maximum number of records in the returned result set.
    # @option options [Integer] :StartRecord The record number at which to start the returned result set.
    # @return [Array] Returns an Array of Hashes representing search results
    def self.all_search(session, options = {})
      response = post('/', :body => build_XML_request('People.All.Search', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['People.All.Search'], ['Results', 'Item']
    end

    # Returns a person's profile data.
    #
    # @see https://api.yourmembership.com/reference/2_00/People_Profile_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] id ID or ProfileID of the person's whose profile data to return.
    # @return [YourMembership::Profile] Returns a Profile object that represents the person's profile
    def self.profile_get(session, id)
      options = {}
      options['ID'] = id

      response = post('/', :body => build_XML_request('People.Profile.Get', session, options))

      response_valid? response
      YourMembership::Profile.new response['YourMembership_Response']['People.Profile.Get']
    end
  end
end
