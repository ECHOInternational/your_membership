module YourMembership
  module Sa
    # YourMembership System Administrator Groups Namespace
    class Groups < YourMembership::Base
      # Returns a list of group membership log entries by Group ID that may be optionally filtered by timestamp.
      # This method will return a maximum of 1,000 results.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Groups_Group_GetMembershipLog.htm
      #
      # @param [Integer] group_id The Group ID of the Membership Log records to be returned.
      # @param [Hash] options
      # @option options [DateTime] :StartDate Filter the returned results by date/time. Only those membership log items which
      #  have been created or updated after the supplied date/time will be returned.
      # @option options [Integer] :ItemID Filter the returned results by sequential ItemID. Only those membership log items
      #  which have a ItemID greater than the supplied integer will be returned. A typical usage scenario for this
      #  parameter would be to supply it when making additional calls while 1,000 records are being returned. You would
      #  supply the last record's ItemID to retrieve the next batch of up to 1,000 records, repeating the process until
      #  no records are returned.
      # @return [Hash] Returns an Hash representing a group's membership Log
      def self.group_getMembershipLog(group_id, options = {}) # rubocop:disable Style/MethodName
        options[:GroupID] = group_id

        response = post('/', :body => build_XML_request('Sa.Groups.Group.GetMembershipLog', nil, options))

        response_valid? response
        response['YourMembership_Response']['Sa.Groups.Group.GetMembershipLog']
      end
    end
  end
end
