require "url_decrufter/version"

require "uri"

module UrlDecrufter
  class UrlFilter
    attr_accessor :uri

    def initialize(uri)
      @uri = uri.dup
    end

    def params
      return [] if @uri.query.nil?
      @uri.query.split("&").map { |p| p.split("=") }
    end
    
    def filtered_params
      params
    end 

    def update_params(new_params)
      # may end up with 0 query params after filtering, in which case set query to
      # nil to avoid trailing '?' on the URL
      if new_params.size > 0
        @uri.query = new_params.map { |name, value | "#{name}=#{value}" }.join("&")
      else
        @uri.query = nil
      end
    end
    
    def filter
      update_params(filtered_params) if filter_applies?
      
      uri
    end
    
    def filter_applies?
      true
    end
    
    def domain
      @uri.host
    end
  end

  class GoogleAnalytics < UrlFilter
    def filtered_params
      params.reject do |name, value|
        name.start_with? "utm_"
      end
    end
  end

  class GUCE < UrlFilter
    def filtered_params
      params.reject do |name, value|
        name.start_with?("guce_") || name == "guccounter"
      end
    end
  end

  # Filter to strip the `cmdf` query param used by The Magic Highlighter (Safari extension)
  class MagicHighlighter < UrlFilter
    def filtered_params
      params.reject do |name, value|
        name == "cmdf"
      end
    end
  end
  
  class OpenSubstack < UrlFilter
    def filtered_params
      params.reject do |name, value|
        name == "r"
      end
    end
    
    def filter_applies?
      domain == "open.substack.com"
    end
  end
  
  

  FILTERS = [GoogleAnalytics, GUCE, MagicHighlighter, OpenSubstack]

  def self.decruft(url)
    uri = URI(url)

    result = FILTERS.reduce(uri) { |uri, filter_class| filter_class.new(uri).filter }

    url.is_a?(String) ? result.to_s : result
  end
end
