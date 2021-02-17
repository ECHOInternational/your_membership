require 'httparty/ym_xml_parser'

module YourMembership
  # Base Class inherited by all Your Membership SDK Classes.
  class Base
    include HTTParty

    base_uri YourMembership.config[:baseUri]

    # rubocop:disable Style/ClassVars

    # Call IDs are usually tied to sessions, this is a unique call id for use whenever a session is not needed.
    @@genericCallID = nil

    # @return [Integer] Auto Increments ad returns the genericCallID as required by the YourMembership.com API
    def self.new_call_id
      if @@genericCallID.nil?
        # We start with a very high number to avoid conflicts when initiating a new session.
        @@genericCallID = 10_000
      else
        @@genericCallID += 1
      end
      @@genericCallID
    end
    # rubocop:enable Style/ClassVars

    # Fix bad XML from YM API by using custom parser.
    # @api private
    # @override HTTParty::ClassMethods#post
    # @return [HTTParty::Response]
    def self.post(path, options = {}, &block)
      opt = options.merge(parser: ::HTTParty::YMXMLParser)
      super(path, opt, &block)
    end

    # A Guard Method that returns true if the response from the API can be processed and raises an exception if not.
    # @param [Hash] response
    # @return [Boolean] true if no errors found.
    # @raise [HTTParty::ResponseError] if a communication error is found.
    def self.response_valid?(response)
      if response.success?
        !response_ym_error?(response)
      else
        raise HTTParty::ResponseError.new(response), 'Connection to YourMembership API failed.'
      end
    end

    # Checks for error codes in the API response and raises an exception if an error is found.
    # @param [Hash] response
    # @return [Boolean] false if no error is found
    # @raise [YourMembership::Error] if an error is found
    def self.response_ym_error?(response)
      if response['YourMembership_Response']['ErrCode'] != '0'
        raise YourMembership::Error.new(
          response['YourMembership_Response']['ErrCode'],
          response['YourMembership_Response']['ErrDesc']
        )
      else
        return false
      end
    end

    # Creates an XML string to send to the API
    # @todo THIS SHOULD BE MARKED PRIVATE and refactored to DRY up the calls.
    def self.build_XML_request(callMethod, session = nil, params = {}) # rubocop:disable Style/MethodLength, Style/MethodName
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        # Root Node Is always <YourMembership>
        xml.YourMembership do
          # API Version
          xml.Version_ YourMembership.config[:version]

          # API Key: For System Administrative tasks it is the private key and
          # passcode, for all others it is the public key
          if callMethod.downcase.start_with?('sa.')
            xml.ApiKey_ YourMembership.config[:privateKey]
            xml.SaPasscode_ YourMembership.config[:saPasscode]
          else
            xml.ApiKey_ YourMembership.config[:publicKey]
          end

          # Pass Session ID and Session Call ID unless there is no session, then
          # send call id from class
          if session
            if session.is_a? YourMembership::Session
              xml.SessionID_ session.session_id
            else
              xml.SessionID_ session
            end
            xml.CallID_ session.call_id
          else
            xml.CallID_ new_call_id
          end

          xml.Call(:Method => callMethod) do
            params.each do |key, value|
              xml_process(key, value, xml)
            end
          end
        end
      end

      builder.to_xml
    end

    # This is a helper method to always return an array (potentially empty) of responses (Hashes) for methods that can
    # have multiple results. The default behavior of the API is to return a nil if no records are found, a hash if one
    # record is found and an array if multiple records are found.
    #
    # @param [Hash] response_body This is the nodeset that returns nil if an empty data set is returned.
    # @param [Array] keys This is a list of keys, in order that are nested inside the response body, these keys will be
    #  traversed in order before retrieving the data associated with the last key in the array
    # @return [Array] A single dimension array of hashes.
    def self.response_to_array_of_hashes(response_body, keys = [])
      return_array = []
      if  response_body
        # http://stackoverflow.com/questions/13259181/what-is-the-most-ruby-ish-way-of-accessing-nested-hash-values-at-arbitrary-depth
        response_body_items = keys.reduce(response_body) { |h, key| h[key] }
        if response_body_items.class == Array
          response_body_items.each do |response_item|
            return_array.push response_item
          end
        else
          return_array.push response_body_items
        end
      end
      return_array
    end

    # Converts the desired portion of the XML response to a single dimension array.
    # This is useful when you don't have a need for key, value pairs and want a clean array of values to work with.
    #
    # @param [Hash] response_body This is the nodeset that returns nil if an empty data set is returned.
    # @param [Array] keys This is a list of keys, in order that are nested inside the response body, these keys will be
    #  traversed in order before retrieving the data associated with the key_for_array
    # @param [String] key_for_array this is the key that represents the list of items you want to turn into an array.
    # @return [Array] A single dimension array of values.
    def self.response_to_array(response_body, keys = [], key_for_array)
      return_array = []
      response_hash_array = response_to_array_of_hashes(response_body, keys)
      response_hash_array.each do |item|
        return_array.push item[key_for_array]
      end
      return_array
    end

    private

    # Convenience method to convert Ruby DateTime objects into ODBC canonical strings as are expected by the API
    # @param [DateTime] dateTime
    # @return [String] An ODBC canonical string representation of a date as is expected by the API
    def self.format_date_string(dateTime)
      dateTime.strftime('%Y-%m-%d %H:%M:%S')
    end

    def self.xml_process(key, value, xml)
      case value
      when Array
        xml_process_array(key, value, xml)
      when Hash
        xml_process_hash(key, value, xml)
      when YourMembership::Profile
        xml_process_profile(value, xml)
      when DateTime
        xml.send(key, format_date_string(value))
      else
        xml.send(key, value)
      end
    end

    def self.xml_process_profile(profile, xml)
      profile.data.each do |k, v|
        xml_process(k, v, xml)
      end
      xml.send('CustomFieldResponses') do
        profile.custom_data.each do |k, v|
          xml_process_custom_field_responses(k, v, xml)
        end
      end
    end

    def self.xml_process_hash(key, value, xml)
      xml.send(key) do
        value.each { |k, v| xml_process(k, v, xml) }
      end
    end

    def self.xml_process_array(key, value, xml)
      xml.send(key) do
        value.each { |tag| xml.send(tag[0], tag[1]) }
      end
    end

    def self.xml_process_custom_field_responses(key, value, xml)
      xml.send('CustomFieldResponse', :FieldCode => key) do
        xml.send('Values') do
          case value
          when Array
            value.each do | item |
              xml.send('Value', item)
            end
          else
            xml.send('Value', value)
          end
        end
      end
    end
  end
end
