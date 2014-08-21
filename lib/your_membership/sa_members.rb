module YourMembership
  module Sa
    # YourMembership System Administrator Members Namespace
    class Members < YourMembership::Base
      # Returns a list of member IDs that may be optionally filtered by timestamp, and/or group membership. This
      # method is provided for data synchronization purposes and will return a maximum of 10,000 results. It would
      # typically be used in conjunction with subsequent calls to Sa.People.Profile.Get for each <ID> returned.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Members_All_GetIDs.htm
      #
      # @param [Hash] options
      # @option options [DateTime] :Timestamp Only accounts created after the this time will be returned
      # @option options [String] :WebsiteID Filter the returned results by sequential WebsiteID.
      # @option options [Array] :Groups Filter the returned results by group membership. [key, value] will translate to
      #  <key>value</key>
      #
      # @return [Array] A list of API IDs for members in your community.
      def self.all_getIDs(options = {}) # rubocop:disable Style/MethodName
        response = post('/', :body => build_XML_request('Sa.Members.All.GetIDs', nil, options))
        response_valid? response
        response['YourMembership_Response']['Sa.Members.All.GetIDs']['Members']['ID']
      end

      # Returns a Hash of recent member activity on your YourMembership Site
      # Returns member community activity information for the purpose of creating a navigation control.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Members_All_RecentActivity.htm
      #
      # @return [Hash] A subset of data is returned for each of the following:
      #
      #  * Newest member
      #  * Latest post
      #  * Latest comment on a post
      #  * Latest photo
      def self.all_recentActivity # rubocop:disable Style/MethodName
        response = post('/', :body => build_XML_request('Sa.Members.All.RecentActivity'))
        response_valid? response
        response['YourMembership_Response']['Sa.Members.All.RecentActivity'].to_h
      end

      # Returns a list of order IDs for a specified member that may be optionally filtered by timestamp and status.
      # This method will return a maximum of 1,000 results.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Members_Commerce_Store_GetOrderIDs.htm
      #
      # @param member_id [String] The id of the person for whom you want to retrieve data
      # @param [Hash] options
      # @option options [DateTime] :Timestamp Filter the returned results by date/time. Only those orders which were
      #  placed after the supplied date/time will be returned.
      # @option options [Symbol, Integer] :Status Filter the returned results by Status.
      #  (-1 = :Cancelled; 0 = :open; 1 = :processed; 2 = :shipped or :closed)
      #
      # @return [Array] A list of Invoice Id Strings
      def self.commerce_store_getOrderIDs(member_id, options = {}) # rubocop:disable Style/MethodName
        options[:ID] = member_id
        if options[:Status]
          options[:Status] = YourMembership::Commerce.convert_order_status(options[:Status])
        end
        response = post('/', :body => build_XML_request('Sa.Members.Commerce.Store.GetOrderIDs', nil, options))
        response_valid? response
        response_to_array response['YourMembership_Response']['Sa.Members.Commerce.Store.GetOrderIDs']['Orders'], ['Order'], 'InvoiceID'
      end

      # Returns Event Registration details for the provided Event and Member ID. Includes all Event Registration details
      # for Primary Registrant and Additional Registrants. If the Event Registration contains a related Custom Form, the
      # form data will be included in the <DataSet> element as it is stored in our database.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Members_Events_Event_Registration_Get.htm
      #
      # @param event_id [Integer] The ID number for the Event you wish to retrieve Event Registration from.
      # @param member_id [Integer] Member's API ID
      #
      # @return [Array] Returns an Array of Hashes that represent registrations by a specific user for a specific event.
      def self.events_event_registration_get(event_id, member_id) # rubocop:disable Style/MethodName
        options = {}
        options[:EventID] = event_id
        options[:ID] = member_id

        response = post('/', :body => build_XML_request('Sa.Members.Events.Event.Registration.Get', nil, options))

        response_valid? response
        response_to_array_of_hashes response['YourMembership_Response']['Sa.Members.Events.Event.Registration.Get'], ['Registrations', 'Registration']
      end

      # Returns a list of a member's referrals.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Members_Referrals_Get.htm
      #
      # @param member_id [String] ID of the person whose referrals to return.
      # @param [Hash] options
      # @option options [DateTime] :Timestamp Filter the returned results by date/time. Only those referred members who
      #  registered after the supplied date/time will be returned.
      #
      # @return [Array] Returns an Array of Hashes that represent a Member's referrals
      def self.referrals_get(member_id, options = {})
        options[:ID] = member_id

        response = post('/', :body => build_XML_request('Sa.Members.Referrals.Get', nil, options))

        response_valid? response
        response_to_array_of_hashes response['YourMembership_Response']['Sa.Members.Referrals.Get'], ['Member']
      end

      # Returns a list of a member's sub-accounts.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Members_SubAccounts_Get.htm
      #
      # @param member_id [String] ID of the person whose sub-accounts to return.
      # @param options [Hash]
      # @option options [Datetime] :Timestamp Filter the returned results by date/time. Only those members who
      #  registered after the supplied date/time will be returned.
      #
      # @return [Array] Returns an Array of Hashes that represent a Member's Subaccounts
      def self.subAccounts_get(member_id, options = {}) # rubocop:disable Style/MethodName
        options[:ID] = member_id

        response = post('/', :body => build_XML_request('Sa.Members.SubAccounts.Get', nil, options))

        response_valid? response
        response_to_array_of_hashes response['YourMembership_Response']['Sa.Members.SubAccounts.Get'], ['Member']
      end

      # Create a CEU Journal Entry.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Members_Certifications_JournalEntry_Create.htm
      #
      # @param member_id [String] ID of the person who owns this certification journal entry.
      # @param ceus_earned [Integer] The number of CEU Credits earned for this journal entry.
      # @param ceus_expire_date [DateTime] The ODBC Date the CEU Credits Expire.
      # @param description [String] Description of this journal entry.
      # @param entry_date [DateTime] Date and time of this journal entry.
      # @param options [Hash]
      # @option options [String] :CertificationId The ID of the certification this journal entry is a part of. If
      #  neither CertificationName nor CertificationID are supplied, the journal entry will not be attached to a
      #  specific certification.
      # @option options [String] :CertificationName For Self-Awarded certification journal entries that are not linked
      #  an existing certification record. This is the same behavior as choosing "Other Certification" and entering a
      #  Self-Awarded journal entry. If neither CertificationName nor CertificationID are supplied, the journal entry
      #  will not be attached to a specific certification.
      # @option options [Decimal] :ScorePercent The decimal representation of a percentage score.
      #  For example, 90% would be 0.90.
      # @option options [String] :CreditTypeCode Unique code for this new Journal Entry's Credit Type.
      #  If absent, the default Credit Type Code will be used.
      #
      # @return [Boolean] Returns true or raises exception.
      def self.certifications_journalEntry_create(member_id, ceus_earned, ceus_expire_date, description, entry_date, options = {}) # rubocop:disable Style/MethodName
        options['ID'] = member_id
        options['CEUsEarned'] = ceus_earned
        options['CEUsExpireDate'] = ceus_expire_date
        options['Description'] = description
        options['EntryDate'] = entry_date

        response = post('/', :body => build_XML_request('Sa.Members.Certifications.JournalEntry.Create', nil, options))
        response_valid? response
      end

      # Creates a new member profile and returns a member object.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Members_Profile_Create.htm
      #
      # @param profile [YourMembership::Profile]
      #
      # @return [YourMembership::Member] A Member object for the member that was just created.
      # @todo: This currently returns an authenticated session for each created user. This may not be the desired
      #  permanent operation of this function.
      def self.profile_create(profile)
        options = {}
        options['profile'] = profile
        response = post('/', :body => build_XML_request('Sa.Members.Profile.Create', nil, options))
        response_valid? response
        YourMembership::Sa::Auth.authenticate(
          YourMembership::Session.create,
          profile.data['Username'],
          profile.data['Password']
        )
      end
    end
  end
end
