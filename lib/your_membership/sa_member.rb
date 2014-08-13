module YourMembership
  module Sa
    # YourMembership System Administrator Member Namespace
    class Member < YourMembership::Base
      # Returns a list of Certifications for the specified user.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Member_Certifications_Get.htm
      #
      # @param [Integer] member_id ID of the person whose certifications to return.
      # @param [Hash] options
      # @option options [Boolean] :IsArchived Include archived certification records in the returned result. Def: True
      # @return [Array] Returns an array of Hashes representing a member's certifications
      def self.certifications_get(member_id, options = {})
        options[:ID] = member_id

        response = post('/', :body => build_XML_request('Sa.Member.Certifications.Get', nil, options))

        response_valid? response
        response_to_array_of_hashes response['YourMembership_Response']['Sa.Member.Certifications.Get'], ['Certification']
      end

      # Returns a list of Certification Journal Entries for the specified user that may be optionally filtered by
      # date, expiration, and paging.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Member_Certifications_Journal_Get.htm
      #
      # @param [Integer] member_id ID of the person whose certifications to return.
      # @param [Hash] options
      # @option options [Boolean] :ShowExpired Include expired journal entries in the returned result.
      # @option options [DateTime] :StartDate Only include Journal Entries that are newer that the supplied date.
      # @option options [Integer] :EntryID Filter the returned results by sequential EntryID. Only those Certification
      #  Journals which have an EntryID greater than the supplied integer will be returned.
      # @option options [String] :CertificationID Filter the Journal Entries returned by the specified Certification ID.
      # @option options [Integer] :PageSize The number of items that are returned per call of this method.
      #  Default is 200 entries.
      # @option options [Integer] :PageNumber PageNumber can be used to retrieve multiple result sets.
      #  Page 1 is returned by default.
      # @return [Array] Returns an array of Hashes representing a member's certification journal entries.
      def self.certifications_journal_get(member_id, options = {})
        options[:ID] = member_id

        response = post('/', :body => build_XML_request('Sa.Member.Certifications.Journal.Get', nil, options))

        response_valid? response
        response_to_array_of_hashes response['YourMembership_Response']['Sa.Member.Certifications.Journal.Get'], ['Entry']
      end
    end
  end
end
