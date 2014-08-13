module YourMembership
  module Sa
    # YourMembership System Administrator Members Namespace
    class NonMembers < YourMembership::Base
      # Returns a list of non-member IDs that may be optionally filtered by timestamp. This method is provided for data
      # synchronization purposes and will return a maximum of 10,000 results. It would typically be used in conjunction
      # with subsequent calls to Sa.People.Profile.Get for each ID returned.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_NonMembers_All_GetIDs.htm
      #
      # @param [Hash] options
      # @option options [DateTime] :Timestamp Only accounts created after the this time will be returned
      # @option options [String] :WebsiteID Filter the returned results by sequential WebsiteID.
      # @option options [Array] :Groups Filter the returned results by group membership. [key, value] will translate to
      #  <key>value</key>
      #
      # @return [Array] A list of API IDs for non-members in your community.
      def self.all_getIDs(options = {}) # rubocop:disable Style/MethodName
        response = post('/', :body => build_XML_request('Sa.NonMembers.All.GetIDs', nil, options))
        response_valid? response
        response['YourMembership_Response']['Sa.NonMembers.All.GetIDs']['NonMembers']['ID']
      end

      # Creates a new non-member profile and returns the new non-member's ID and WebsiteID. The returned ID must be
      # supplied when performing future updates to the non-member's profile. The returned WebsiteID represents the
      # numeric identifier used by the YourMembership.com application for navigation purposes.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_NonMembers_Profile_Create.htm
      #
      # @param [YourMembership::Profile] profile
      # @return [Hash] The ID and WebsiteID of the nonmember created
      def self.profile_create(profile)
        options = {}
        options['profile'] = profile
        response = post('/', :body => build_XML_request('Sa.NonMembers.Profile.Create', nil, options))
        response_valid? response
        response['YourMembership_Response']['Sa.NonMembers.Profile.Create']
      end
    end
  end
end
