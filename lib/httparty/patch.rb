require 'cgi'

# Monkey Patch for the HTTParty Gem
module HTTParty
  # In order to parse the HTML encoded documents returned by the YourMembership
  # API we need to HTML decode the <![CDATA[ tags. This is a bug workaround.
  class Request
    # This is the encode_body method from HTTParty's Request Class adding an additional method call to fix
    # the CDATA elements that are improperly formatted in the YourMembership API's XML. This is done here to ensure that
    # the fix is in place before the data is parsed.
    def encode_body(body)
      body = fix_cdata body
      if ''.respond_to?(:encoding)
        _encode_body(body)
      else
        body
      end
    end

    # Bug Fix for HTML encoded < and > in XML body.
    # @param body [String] an XML document that needs to be checked for this specific issue.
    # @return [String] If the HTML encoding issue is found it is repaired and the document is returned.
    def fix_cdata(body)
      # <![CDATA[ = &lt;![CDATA[
      # ]]> =  ]]&gt;
      if body.present? && body.include?('&lt;![CDATA[')
        body.gsub! '&lt;![CDATA[', '<![CDATA['
        body.gsub! ']]&gt', ']]>'
      end
      body
    end
  end
end
