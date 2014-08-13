module YourMembership
  # YourMembership Convert Namespace
  class Convert < YourMembership::Base
    # Converts the given local time to current Eastern Time, factoring in adjustments for Daylight Savings Time.
    # @see https://api.yourmembership.com/reference/2_00/Convert_ToEasternTime.htm
    #
    # @param [YourMembership::Session] session
    # @param [DateTime] localTime A DateTime that you want to convert to US/Eastern Time
    # @param [Integer] localGMTBias The Number of hours the local time zone is away from GMT
    # @return [Hash] Returns an Hash with 'Converted' and 'ServerGmtBias'
    # @note This is probably not necessary as Ruby will happily convert dates.
    def self.ToEasternTime(session, localTime, localGMTBias) # rubocop:disable Style/MethodName
      options = {}
      options[:LocalTime] = format_date_string localTime
      options[:LocalGmtBias] = localGMTBias

      response = post('/', :body => build_XML_request('Convert.ToEasternTime', session, options))

      if response_valid? response
        response['YourMembership_Response']['Convert.ToEasternTime']
      end
    end
  end
end
