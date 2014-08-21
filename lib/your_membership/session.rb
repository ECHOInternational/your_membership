module YourMembership
  # YourMembership Session Object
  #
  # Session objects encapsulate the creation, storage, authentication, maintenance, and destruction of sessions in the
  # YourMembership.com API.
  #
  # @note It is important to note that the Auth Namespace has been consumed by Sessions in the SDK as sessions and
  #  authentication are inextricably linked.
  #
  # Sessions can be *generic* (unauthenticated), *authenticated*, or *abandoned*.
  #
  # * *Generic sessions* are used extensively whenever the scope of a specific user is not necessary.
  # * *Authenticated sessions* are used when the called method requires the scope of a specific user.
  # * *Abandoned sessions* are no longer usable and are essentially the same as logging out.
  #
  # @example Generic (unauthenticated) Session
  #  session = YourMembership::Session.create # => <YourMembership::Session>
  # @example Authenticated Session
  #  auth_session = YourMembership::Session.create 'username', 'password' # => <YourMembership::Session>
  #
  # @attr_reader [String] session_id The unique session identifier provided by the API
  # @attr_reader [String, Nil] user_id The user id of the user bound to the session, if one exists.
  class Session < YourMembership::Base
    attr_reader :session_id, :user_id, :call_id

    # Generates an empty session
    def initialize(session_id = nil, call_id = 1, user_id = nil)
      @session_id = session_id
      @call_id = call_id
      @user_id = user_id
    end

    # @see https://api.yourmembership.com/reference/2_00/Session_Create.htm
    # @param user_name [String] Constructor takes optional parameters of user_name and password. If supplied then the
    #  session will be automatically authenticated upon instantiation.
    # @param password [String]
    def create(user_name = nil, password = nil)
      response = self.class.post('/', :body => self.class.build_XML_request('Session.Create'))

      if self.class.response_valid? response
        session = new response['YourMembership_Response']['Session.Create']['SessionID']
      end

      session.authenticate user_name, password if user_name
      session
    end

    # @return [Integer] Auto Increments ad returns the call_id for the session as required by the YourMembership.com API
    def call_id
      @call_id += 1
    end

    # @return [String] Returns the session_id
    def to_s
      @session_id
    end

    # Destroys an API session, thus preventing any further calls against it.
    #
    # @see https://api.yourmembership.com/reference/2_00/Session_Abandon.htm
    #
    # @return [Boolean] Returns true if the session was alive and successfully abandoned.
    def abandon
      response = self.class.post('/', :body => self.class.build_XML_request('Session.Abandon', self))
      self.class.response_valid? response
    end

    # When called at intervals of less than 20 minutes, this method acts as an API session keep-alive.
    #
    # @see https://api.yourmembership.com/reference/2_00/Session_Ping.htm
    #
    # @return [Boolean] Returns true if the session is still alive.
    def ping
      response = self.class.post('/', :body => self.class.build_XML_request('Session.Ping', self))
      self.class.response_valid? response
      response['YourMembership_Response']['Session.Ping'] == '1'
    end

    # Convenience method for ping.
    def valid?
      ping
    end

    # Authenticates a member's username and password and binds them to the current API session.
    #
    # @see https://api.yourmembership.com/reference/2_00/Auth_Authenticate.htm
    #
    # @param user_name [String] The username of the member that is being authenticated.
    # @param password [String] The clear text password of the member that is being authenticated.
    #
    # @return [Hash] Returns the member's ID and WebsiteID. The returned WebsiteID represents the numeric identifier
    #  used by the YourMembership.com application for navigation purposes. It may be used to provide direct navigation to
    #  a member's profile, photo gallery, personal blog, etc.
    def authenticate(user_name, password)
      options = {}
      options[:Username] = user_name
      options[:Password] = password

      response = self.class.post('/', :body => self.class.build_XML_request('Auth.Authenticate', self, options))

      self.class.response_valid? response
      if response['YourMembership_Response']['Auth.Authenticate']
        get_authenticated_user
      else
        false
      end
    end

    # Creates an AuthToken that is bound to the current session. The returned token must be supplied to the Sign-In
    # form during member authentication in order to bind a member to their API session. The sign-in URL, which will
    # include the new AuthToken in its query-string, is returned by this method as GoToUrl. Tokens expire after a short
    # period of time, so it is suggested that the user be immediately redirected the returned GoToUrl after creating an
    # authentication token.
    #
    # @see https://api.yourmembership.com/reference/2_00/Auth_CreateToken.htm
    #
    # @param options [Hash]
    # @option options [String] :RetUrl After authentication the browser will be redirected to this URL
    # @option options [String] :Username The user can optionally be logged in automatically if :Username and :Password
    #  are supplied in cleartext.
    # @option options [String] :Password The user's password
    # @option options [Boolean] :Persist Supplying this value is only necessary when also providing user credentials for
    #  automated authentication. The purpose of enabling persistence is to extend an authenticated user's browsing
    #  session beyond its normal inactivity threshold of 20 minutes.
    #
    # @return [Hash] Contains the token String and a URL that will authenticate the session based on that token.
    def createToken(options = {}) # rubocop:disable Style/MethodName
      # Options inlclude: :RetUrl(String), :Username(String),
      # :Password(String), :Persist(Boolean)

      response = self.class.post('/', :body => self.class.build_XML_request('Auth.CreateToken', self, options))

      self.class.response_valid? response
      response['YourMembership_Response']['Auth.CreateToken']
    end

    # Indicates whether the session is bound to a user.
    def authenticated?
      if valid?
        !get_authenticated_user.nil?
      else
        false
      end
    end

    # Get the ID of the currently authenticated user bound to this session.
    # @return [String, Nil] The API ID of the currently authenticated user
    def get_authenticated_user # rubocop:disable Style/AccessorMethodName
      @user_id = YourMembership::Member.isAuthenticated(self)
    end
  end
end
