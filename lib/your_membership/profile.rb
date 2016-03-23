module YourMembership
  # The Profile object provides a convenient abstraction that encapsulates a person's profile allowing clear and concise
  # access to both the core fields provided by YourMembership and the custom fields added by site administrators
  #
  # A new profile for a new person should be instantiated through the create_new method
  #
  # A profile can be loaded by passing a hash directly to the initializer (Profile.new) method this can be useful in
  # creating a profile object from an API response
  #
  # A profile can be created empty or by passing a hash for standard and/or custom fields. This is useful for
  # updating an existing profile without changing unnecessary records.
  #
  # @attr_reader [Hash] data These are fields that are part of the core YourMembership profile implementation
  # @attr_reader [Hash] custom_data These are fields that are the ones added as Custom Fields to a YourMembership
  #  Community
  class Profile
    attr_accessor :data, :custom_data

    # @param [Hash] options Initial Values for the profile.
    def initialize(options = {})
      @data = {}
      @custom_data = {}

      options.each do |k, v|
        if k == 'CustomFieldResponses'
          @custom_data = parse_custom_field_responses(v)
        else
          @data[k] = v
        end
      end
    end

    # Returns the full contents of the profile in a Hash without items that have a Nil value
    # @return [Hash]
    def to_h
      temp_data = clean @data
      temp_custom_data = clean @custom_data
      temp_data['CustomFieldResponses'] = temp_custom_data
      temp_data
    end

    # @param [String] last_name
    # @param [String] member_type_code
    # @param [String] email
    # @param [String] username
    # @param [String] password
    # @param [Hash] options
    # @return [YourMembership::Profile] Builds a new profile with required and optional fields
    # @note: It has been found that for some users you must also specify a 'Membership' field as well as the
    #  'MemberTypeCode' The official documentation does not say this field is required but many times the user
    #  cannot log in if no membership is provided. This means that the system cannot masquerade as this user until a
    #  membership is specified.
    def self.create_new(first_name, last_name, member_type_code, email, username, password, options = {})
      options['FirstName'] = first_name
      options['LastName'] = last_name
      options['MemberTypeCode'] = member_type_code
      options['EmailAddr'] = email
      options['Username'] = username
      options['Password'] = password
      new(options)
    end

    private

    # @param [Hash] custom_fields The 'CustomFieldResponses' Hash
    # @return [Hash] Single dimension hash containing keys and values as strings or arrays
    def parse_custom_field_responses(custom_fields)
      return {} unless custom_fields

      # CustomFieldResponse may be an array (if multiple responses) or a hash
      # (if single response). Make sure we're always dealing with an array.
      responses = custom_fields['CustomFieldResponse']
      responses = [responses] unless responses.is_a?(Array)

      output_hash = {}
      responses.each do |field|
        output_hash[field['FieldCode']] = field['Values']['Value'] if field['Values']
      end
      output_hash
    end

    # Removes nil values
    def clean(data_hash)
      clean_hash = {}
      # Remove Nils
      data_hash.each do |k, v|
        clean_hash[k] = v if v
      end
      clean_hash
    end
  end
end
