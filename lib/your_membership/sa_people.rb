module YourMembership
  module Sa
    # YourMembership System Administrator Members Namespace
    class People < YourMembership::Base
      # Returns a list of member and non-member IDs that may be optionally filtered by timestamp. This method is
      # provided for data synchronization purposes and will return a maximum of 10,000 results. It would typically be
      # used in conjunction with subsequent calls to Sa.People.Profile.Get for each ID returned
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_People_All_GetIDs.htm
      #
      # @param [Hash] options
      # @option options [DateTime] :Timestamp Only accounts created after the this time will be returned
      # @option options [String] :WebsiteID Filter the returned results by sequential WebsiteID.
      # @option options [Array] :Groups Filter the returned results by group membership. [key, value] will translate to
      #  <key>value</key>
      #
      # @return [Array] A list of API IDs for non-members in your community.
      def self.all_getIDs(options = {}) # rubocop:disable Style/MethodName
        response = post('/', :body => build_XML_request('Sa.People.All.GetIDs', nil, options))
        response_valid? response
        response['YourMembership_Response']['Sa.People.All.GetIDs']['People']['ID']
      end

      # Finds and returns a member or non-member <ID> using Import ID, Constituent ID or Website/Profile ID as criteria.
      # If a single ID cannot be uniquely identified based on the criteria supplied then error code 406 is returned.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_People_Profile_FindID.htm
      #
      # @param [Hash] options
      # @option options [String] :ImportID Import ID of the person whose ID you are trying to find.
      # @option options [String] :ConstituentID Constituent ID of the person whose ID you are trying to find.
      # @option options [Integer] :WebsiteID Website/Profile ID of the person whose ID you are trying to find.
      # @option options [String] :Username Username of the person whose ID you are trying to find.
      # @option options [String] :Email Email Address of the person whose <ID> you are trying to find.
      #  May return multiple <ID>'s as Email Address is not unique.
      #
      # @return [String] if a single record is found (normal for all calls except for :Email)
      # @return [Array] if multiple records are found (possible only for :Email searches)
      def self.profile_findID(options = {}) # rubocop:disable Style/MethodName
        response = post('/', :body => build_XML_request('Sa.People.Profile.FindID', nil, options))
        response_valid? response
        response['YourMembership_Response']['Sa.People.Profile.FindID']['ID']
      end

      # Returns a person's profile data.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_People_Profile_Get.htm
      #
      # @param [String] id ID of the person whose profile data to return.
      # @return [YourMembership::Profile] Returns a Profile object that represents the person's profile
      def self.profile_get(id)
        options = {}
        options[:ID] = id
        response = post('/', :body => build_XML_request('Sa.People.Profile.Get', nil, options))
        response_valid? response
        YourMembership::Profile.new response['YourMembership_Response']['Sa.People.Profile.Get']
      end

      # Returns a person's group relationship data. There are three types of relationships that members may have with
      # particular groups; "Administrator", "Member" and "Representative". Groups are listed within nodes respective
      # of their relationship type.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_People_Profile_Groups_Get.htm
      #
      # @param [String] id ID of the person whose profile data to return.
      # @return [Hash] Returns a Hash that represents the person's group relationships
      def self.profile_groups_get(id)
        options = {}
        options[:ID] = id
        response = post('/', :body => build_XML_request('Sa.People.Profile.Groups.Get', nil, options))

        response_valid? response
        response['YourMembership_Response']['Sa.People.Profile.Groups.Get']
      end

      # Updates an existing person's profile.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_People_Profile_Update.htm
      #
      # @param [String] id ID of the person whose profile is to be updated.
      # @param [YourMembership::Profile] profile The profile object containing the fields to be updated
      # @return [Boolean] Will raise and exception or return TRUE
      def self.profile_update(id, profile)
        options = {}
        options['ID'] = id
        options['profile'] = profile
        response = post('/', :body => build_XML_request('Sa.People.Profile.Update', nil, options))
        response_valid? response
      end
    end
  end
end
