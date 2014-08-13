module YourMembership
  module Sa
    # YourMembership System Administrator Certifications Namespace
    class Certifications < YourMembership::Base
      # Return a list of all certification records for the community.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Certifications_All_Get.htm
      #
      # @param [Boolean] is_active Include active certification records in the returned result. Default: True
      # @return [Array] Returns an Array of Hashes representing Certification Records
      def self.all_get(is_active = true)
        options = {}
        options[:IsActive] = is_active

        response = post('/', :body => build_XML_request('Sa.Certifications.All.Get', nil, options))

        response_valid? response
        response_to_array_of_hashes response['YourMembership_Response']['Sa.Certifications.All.Get'], ['Certification']
      end
    end
  end
end
