require 'httparty/parser'

module HTTParty
  # Bug Fix for HTML encoded < and > in XML body. In order to parse the HTML
  # encoded documents returned by the YourMembership API we need to HTML decode
  # the <![CDATA[ tags.
  #
  # @api private
  class YMXMLParser < HTTParty::Parser
    # @api private
    # @override
    def body
      decode(@body)
    end

    private

    # @api private
    def decode(body)
      # <![CDATA[ = &lt;![CDATA[
      # ]]> =  ]]&gt;
      if !body.nil? && body.include?('&lt;![CDATA[')
        body.gsub! '&lt;![CDATA[', '<![CDATA['
        body.gsub! ']]&gt;', ']]>'
      end
      body
    end
  end
end
