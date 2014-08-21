module YourMembership
  # The member object provides a convenient abstraction that encapsulates the member methods and caches some basic
  # details about the member.
  #
  # @attr_reader [String] id The API ID of the member.
  # @attr_reader [String] website_id The WebsiteID of the member which is used to construct urls for member navigation.
  # @attr_reader [String] full_name The COMPUTED full_name of the member. This is implemented through the full_name
  #  method so as to allow this method to be easily overridden if a different format is desired.
  # @attr [String] first_name The First Name of the member.
  # @attr [String] last_name The Last Name of the member.
  # @attr [String] email The email address associated with the member.
  # @attr [YourMembership::Session] session The Session object bound to this member through authentication.
  # @attr [YourMembership::Profile] profile A session object bound to this member object. This must be set manually.
  class Member < YourMembership::Base
    attr_reader :id, :website_id
    attr_accessor :first_name, :last_name, :email, :session, :profile

    # Member Initializer - Use Member.create_from_session or Member.create_by_authentication to instantiate
    # objects of this type.
    #
    # @note There is not yet a compelling reason to call Member.new() directly, however it can be done.
    #
    # @param [String] id The API ID of the member.
    # @param [String] website_id The WebsiteID of the member which is used to construct urls for member navigation.
    # @param [String] first_name The First Name of the member.
    # @param [String] last_name The Last Name of the member.
    # @param [String] email The email address associated with the member.
    # @param [YourMembership::Session, Nil] session The Session object bound to this member through authentication.
    def initialize(id, website_id, first_name, last_name, email, session = nil)
      @id = id
      @website_id = website_id
      @first_name = first_name
      @last_name = last_name
      @email = email
      @session = session
      @profile = nil
    end

    # Format name parts in to a full name string.
    # If you wish different behavior (perhaps 'last_name, first_name') this method should be overridden.
    #
    # @return [string] Returns a formatted name.
    def full_name
      @first_name + ' ' + @last_name
    end

    # Allow an instance to call all class methods (unless they are specifically restricted) and pass the session and
    # arguments of the current object.
    def method_missing(name, *args)
      if [:create_by_authentication, :create_from_session].include? name
        raise NoMethodError.new("Cannot call method #{name} on class #{self.class} because it is specifically denied.", 'Method Protected')
      else
        self.class.send(name, @session, *args)
      end
    end

    # Creates a new Member object through username and password authentication.
    # @param [String] username The username in cleartext
    # @param [String] password The password in cleartext
    # @return [YourMembership::Member] Returns a new Member object with associated authenticated Session object
    def self.create_by_authentication(username, password)
      session = YourMembership::Session.create username, password
      create_from_session(session)
    end

    # Creates a new Member object from a previously authenticated Session object.
    # @param [YourMembership::Session] session A previously authenticated Session.
    # @return [YourMembership::Member] Returns a new Member object
    def self.create_from_session(session)
      profile = profile_getMini session
      new(
        profile['ID'],
        profile['WebsiteID'],
        profile['FirstName'],
        profile['LastName'],
        profile['EmailAddr'],
        session
      )
    end

    # Returns a list of Certifications for the specified user.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Certifications_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [Hash] options
    # @option options [Boolean] :IsArchived Include archived certification records in the returned result. Default: True
    #
    # @return [Array] An Array of Hashes representing the Certifications of the authenticated user.
    def self.certifications_get(session, options = {})
      response = post('/', :body => build_XML_request('Member.Certifications.Get', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Member.Certifications.Get'], ['Certification']
    end

    # Returns a list of Certification Journal Entries for the signed in user that may be optionally filterd by date,
    # expiration, and paging.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Certifications_Journal_Get.htm
    #
    # @param [YourMembership::Session] session
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
    #
    # @return [Array] An Array of Hashes representing the Certification Journal Entries of the authenticated user.
    def self.certifications_journal_get(session, options = {})
      response = post('/', :body => build_XML_request('Member.Certifications.Journal.Get', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Member.Certifications.Journal.Get'], ['Entry']
    end

    # Returns a list of order IDs for the authenticated user that may be optionally filtered by timestamp and status.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Commerce_Store_GetOrderIDs.htm
    #
    # @param [YourMembership::Session] session
    # @param [Hash] options
    # @option options [DateTime] :Timestamp Filter the returned results by date/time. Only those orders which were
    #  placed after the supplied date/time will be returned.
    # @option options [Symbol, Integer] :Status Filter the returned results by Status.
    #  (-1 = :Cancelled; 0 = :open; 1 = :processed; 2 = :shipped or :closed)
    #
    # @return [Array] A list of Invoice Id Strings for the authenticated user.
    def self.commerce_store_getOrderIDs(session, options = {}) # rubocop:disable Style/MethodName
      if options[:Status]
        options[:Status] = YourMembership::Commerce.convert_order_status(options[:Status])
      end

      response = post('/', :body => build_XML_request('Member.Commerce.Store.GetOrderIDs', session, options))

      response_valid? response
      response_to_array response['YourMembership_Response']['Member.Commerce.Store.GetOrderIDs']['Orders'], ['Order'], 'InvoiceID'
    end

    # Returns the order details, including line items and products ordered, of a store order placed by the authenticated
    # member.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Commerce_Store_Order_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] invoiceID The Invoice ID of the store order to be returned.
    # @return [Hash] Returns a Hash representing a users order referenced by the invoiceID
    #
    # @note This method depends on the HTTParty Monkey Patch that HTML Decodes response bodies before parsing.
    #  YourMembership returns invalid XML when embedding <![CDATA] elements.
    def self.commerce_store_order_get(session, invoiceID)
      options = {}
      options[:InvoiceID] = invoiceID

      response = post('/', :body => build_XML_request('Member.Commerce.Store.Order.Get', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Member.Commerce.Store.Order.Get'], ['Order']
    end

    # Approves or declines a connection request.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Connection_Approve.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] id ID or Profile ID of the member to approve/decline.
    # @param [Boolean] approve 0 or 1 to decline or approve a connection 0 = Decline, 1 = Approve
    def self.connection_approve(session, id, approve)
      options = {}
      options[:ID] = id
      options[:Approve] = approve
      response = post('/', :body => build_XML_request('Member.Connection.Approve', session, options))
      response_valid? response
    end

    # Creates An XML Body for submission with a file to the authenticated member's media gallery.
    # Valid files must be an RGB image in GIF, JPEG or PNG format.
    # API requests must be submitted as multipart/form-data with the XML API request submitted in the named field value
    # XMLMessage. This function returns a string that can be embedded as this field value.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_MediaGallery_Upload.htm
    #
    # @param [YourMembership::Session] session
    # @param [Hash] options
    # @option options [Integer] :AlbumID AlbumID of the media gallery item to submit to.
    # @option options [String] :Caption Caption to be associated with the media gallery item. (Limited to 150 Chars.)
    # @option options [String] :AllowComments Setting for allowing comments. Available values are:
    #  :all = Comments are allowed
    #  :connections = Comments limited to a member's connections
    #  :none = Comments not allowed
    # @option options [Boolean] :IsPublic Setting for allowing anonymous visitors to view uploaded photos for public
    #  member types. True makes the image visible to everyone, False makes the image only available to Members.
    # @return [String] This string should be submitted as the XMLMessage field in a multipart/form-data post to
    #  https://api.yourmembership.com/
    def self.mediaGallery_upload(session, options = {}) # rubocop:disable Style/MethodName
      build_XML_request('Member.MediaGallery.Upload', session, options)
    end

    # Returns a list of messages from the authenticated member's Inbox. Returns a maximum of 100 records per request.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Messages_GetInbox.htm
    #
    # @param [YourMembership::Session] session
    # @param [Hash] options
    # @option options [Integer] :PageSize The maximum number of records in the returned result set.
    # @option options [Integer] :StartRecord The record number at which to start the returned result set.
    # @return [Array] Returns an Array of Hashes representing a member's inbox messages
    #
    # @note BUG WORKAROUND: The API documentation indicates that GetInbox should return an <GetInbox> XML structure, but
    #  instead it returns <Get.Inbox>
    def self.messages_getInbox(session, options = {}) # rubocop:disable Style/MethodName
      response = post('/', :body => build_XML_request('Member.Messages.GetInbox', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Members.Messages.Get.Inbox'], ['Message']
    end

    # Returns a list of messages from the authenticated member's Sent folder, Returns a maximum of 100 records per
    # request.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Messages_GetSent.htm
    #
    # @param [YourMembership::Session] session
    # @param [Hash] options
    # @option options [Integer] :PageSize The maximum number of records in the returned result set.
    # @option options [Integer] :StartRecord The record number at which to start the returned result set.
    # @return [Array] Returns an Array of Hashes representing a member's sent messages
    #
    # @note BUG WORKAROUND: The API documentation indicates that GetInbox should return an <GetSent> XML structure, but
    #  instead it returns <Get.Sent>
    def self.messages_getSent(session, options = {}) # rubocop:disable Style/MethodName
      response = post('/', :body => build_XML_request('Member.Messages.GetSent', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Members.Messages.Get.Sent'], ['Message']
    end

    # Returns an individual message by MessageID and marks it as read.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Messages_Message_Read.htm
    #
    # @param [YourMembership::Session] session
    # @param [Integer] message_id The ID of the Message to be returned.
    # @return [Hash] Returns a has of all of the message's fields.
    def self.messages_message_read(session, message_id)
      options = {}
      options[:MessageID] = message_id
      response = post('/', :body => build_XML_request('Member.Messages.Message.Read', session, options))

      response_valid? response
      # Note that the response key is not the same as the request key, this could just be a typo in the API
      response['YourMembership_Response']['Members.Messages.Message.Read']['Message']
    end

    # Message a member.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Messages_Message_Send.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] member_id ID or ProfileID of the member to send a message.
    # @param [String] subject Subject line of the message.
    # @param [String] body Body of the message.
    # @return [Boolean] True if successful
    def self.messages_message_send(session, member_id, subject, body)
      options = {}
      options[:ID] = member_id
      options[:Subject] = subject
      options[:Body] = body
      response = post('/', :body => build_XML_request('Member.Messages.Message.Send', session, options))
      response_valid? response
    end

    # Upon validating Username or Email Address given, sends an email to matching members with a link needed to reset
    # their password. This method does not require authentication.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Password_InitializeReset.htm
    #
    # @param [YourMembership::Session] session
    # @param [Hash] options
    # @option options [String] :Username Username of the member
    # @option options [String] :EmailAddress Email Address of the member
    # @return [Boolean] Returns True if successful
    def self.password_initializeReset(session, options = {}) # rubocop:disable Style/MethodName
      response = post('/', :body => build_XML_request('Member.Password.InitializeReset', session, options))
      response_valid? response
    end

    # After validating ResetToken or CurrentPassword given, this method updates the associated member's password to the
    # new value. This method requires Authentication only when passing in CurrentPassword parameter.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Password_Update.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] new_password The new password to use.
    # @param [Hash] options
    # @option options [String] :CurrentPassword Member's current password. The API request must be Authenticated when
    #  using this parameter. Used when members are signed in, but want to change their password.
    # @option options [String] :ResetToken Reset Token from the Password Reset email.
    # @return [Boolean] Returns True if successful
    def self.password_update(session, new_password, options = {})
      options[:NewPassword] = new_password
      response = post('/', :body => build_XML_request('Member.Password.Update', session, options))
      response_valid? response
    end

    # Returns the authenticated member's profile data.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Profile_Get.htm
    #
    # @param [YourMembership::Session] session
    # @return [YourMembership::Profile] Returns a Profile object that represents the person's profile
    def self.profile_get(session)
      response = post('/', :body => build_XML_request('Member.Profile.Get', session))

      response_valid? response
      YourMembership::Profile.new response['YourMembership_Response']['Member.Profile.Get']
    end

    # Returns a subset of the authenticated member's profile data along with statistics and permissions for the purpose
    # of creating a profile snapshot and navigation control.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Profile_Get.htm
    #
    # @param [YourMembership::Session] session
    # @return [Hash] Returns a Hash of details and permissions for the authenticated user.
    def self.profile_getMini(session) # rubocop:disable Style/MethodName
      response = post('/', :body => build_XML_request('Member.Profile.GetMini', session))

      response_valid? response
      response['YourMembership_Response']['Member.Profile.GetMini']
    end

    # Post to a member's wall.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_Wall_Post.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] post_text Text to post on the member's wall.
    # @param [String] id ID or ProfileID of any member that is connected to the authenticated member whose wall to post
    #  on. Omit this argument to post on the authenticated member's own wall.
    # @return [Boolean] True if successful
    def self.wall_post(session, post_text, id = nil)
      options = {}
      options[:ID] = id if id
      options[:PostText] = post_text
      response = post('/', :body => build_XML_request('Member.Wall.Post', session, options))
      response_valid? response
    end

    # Validates that the current session has been authenticated by returning the authenticated member's ID.
    #
    # @see https://api.yourmembership.com/reference/2_00/Member_IsAuthenticated.htm
    #
    # @param [YourMembership::Session] session
    # @return [String] if provided session is authenticated returns the members's ID
    # @return [Nil] if provided session is not authenticated
    #  returns nil.
    def self.isAuthenticated(session) # rubocop:disable Style/MethodName
      response = post('/', :body => build_XML_request('Member.IsAuthenticated', session))

      # Fail on HTTP Errors
      raise HTTParty::ResponseError.new(response), 'Connection to YourMembership API failed.' unless response.success?

      error_code = response['YourMembership_Response']['ErrCode']

      # Error Code 202 means that the session itself has expired, we don't
      # want to throw an exception for that, just return that the session is
      # not authenticated.
      return nil if error_code == '202'

      # Error Code 403 means that the method requires Authentication, if the
      # call is not authenticated then the session cannot be authenticated.
      return nil if error_code == '403'

      # All Error Codes other than 403 inidicate an unrecoverable issue that
      # we need to raise an exception for.
      raise YourMembership::Error.new(
        response['YourMembership_Response']['ErrCode'],
        response['YourMembership_Response']['ErrDesc']
      ) if error_code != '0'

      if response['YourMembership_Response']['Member.IsAuthenticated']
        # If everything is ok retun the authenticated users ID
        return response['YourMembership_Response']['Member.IsAuthenticated']['ID']
      else
        # If there is no ID in the data returned then the session is not
        # authenticated.
        nil
      end
    end
  end
end
