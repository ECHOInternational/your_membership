module YourMembership
  # Custom exception for YourMembership error codes.
  # @attr [Integer] error_code The Error Code
  # @attr [String] error_description A Description of what the error means.
  class Error < StandardError
    attr_accessor :error_code, :error_description

    # @param [Integer] error_code The Error Code
    # @param [String] error_description A Description of what the error means.
    # @see https://api.yourmembership.com/reference/2_00/Error_Codes.htm
    def initialize(error_code, error_description)
      self.error_code = error_code
      self.error_description = error_description
    end

    # @return [String] A highly readable error message.
    def to_s
      "Your Membership Returned An Error Code: #{error_code} With Message: #{error_description}"
    end
  end
end
