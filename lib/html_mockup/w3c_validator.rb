require 'cgi'
require 'net/http'
require 'uri'
require 'yaml'

module HtmlMockup
  class W3CValidator
  
    ValidationUri = "http://validator.w3.org/check"
    
    class RequestError < StandardError; end
  
    attr_reader :valid,:response,:errors,:warnings,:status
  
    class << self
      def validation_uri
        @uri ||= URI.parse(ValidationUri)
      end
    end 
  
    def initialize(html)
      @html = html
    end
  
    def validate!
      @status = @warnings = @errors = @response = @valid = nil
      options = {"output" => "json"}
      query,headers = build_post_query(options)
      response =  self.request(:post,self.class.validation_uri.path,query,headers)
      @status,@warnings,@errors = response["x-w3c-validator-status"],response["x-w3c-validator-warnings"].to_i,response["x-w3c-validator-errors"].to_i
    
      if @status == "Valid" && @warnings == 0 && @errors == 0
        return @valid = true
      else
        begin
          @response = YAML.load(response.body)
        rescue 
        end
        return (@valid = (@errros == 0))
      end
    
    end
  
    protected
  
    def build_post_query(options)
      boundary = "validate-this-content-please"
      headers = {"Content-type" => "multipart/form-data, boundary=" + boundary + " "}
    
      parts = []
      options.each do |k,v|
        parts << post_param(k,v)
      end
      parts << file_param("uploaded_file","index.html",@html,"text/html")
    
      q = parts.map{|p| "--#{boundary}\r\n#{p}"}.join("") + "--#{boundary}--"
      [q,headers]
    end
  
    def post_param(k,v)
      "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
    end
  
    def file_param(k,filename,content,mime_type)
      out = []
      out << "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{filename}\""
      out << "Content-Transfer-Encoding: binary"
      out << "Content-Type: #{mime_type}"
      out.join("\r\n") + "\r\n\r\n" + content + "\r\n"
    end
    
    # Makes request to remote service.
    def request(method, path, *arguments)
      perform_request(method, path, arguments, 3)
    end
    
    def perform_request(method, path, arguments, tries=3)
      result = nil
      result = http.send(method, path, *arguments)
      handle_response(result)
    rescue RequestError => e
      if tries > 0
        perform_request(method, path, arguments, tries-1)
      else
        raise
      end
    rescue Timeout::Error => e
      raise       
    end
  
    # Handles response and error codes from remote service.
    def handle_response(response)
      case response.code.to_i
        when 301,302
          raise "Redirect"
        when 200...400
          response
        when 400
          raise "Bad Request"
        when 401
          raise "Unauthorized Access"
        when 403
          raise "Forbidden Access"
        when 404
          raise "Rescoure not found"
        when 405
          raise "Method not allowed"
        when 409
          raise RequestError.new("Rescource conflict")
        when 422
          raise RequestError.new("Resource invalid")
        when 401...500
          raise "Client error"
        when 500...600
          raise RequestError.new("Server error")
        else
          raise "Unknown response: #{response.code.to_i}"
      end
    end
        
    def http
      site = self.class.validation_uri
      http = Net::HTTP.new(site.host, site.port)
  #    http.use_ssl = site.is_a?(URI::HTTPS)
  #    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl
      http
    end      
  end
end