module YourMembership
  module Sa
    # YourMembership System Administrator Member Authentication
    class Auth < YourMembership::Base
      # Authenticates a member's username and password and binds them to the current API session.
      #
      # @see https://api.yourmembership.com/reference/2_00/Sa_Auth_Authenticate.htm
      #
      # @param [YourMembership::Session] session
      # @param [String] user_name The Username of the user the session should be bound to.
      # @param [String] password The Password (Optional) pf the specified user.
      # @param [String] password_hash The Password Hash for the specified user which allows the system to perform
      #  actions on behalf of a user as if they were signed in without knowing the user's cleartext password.
      # @return [YourMembership::Member] Returns a Member object for the authenticated session.
      def self.authenticate(session, user_name, password = nil, password_hash = nil)
        options = {}
        options[:Username] = user_name
        options[:Password] = password if password
        options[:PasswordHash] = password_hash if password_hash

        response = post('/', :body => build_XML_request('Sa.Auth.Authenticate', session, options))

        response_valid? response
        if response['YourMembership_Response']['Sa.Auth.Authenticate']
          session.get_authenticated_user
        else
          return false
        end

        YourMembership::Member.create_from_session(session)
      end
    end
  end
end
