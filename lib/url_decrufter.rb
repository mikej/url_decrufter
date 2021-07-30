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

    def update_params(new_params)
      # may end up with 0 query params after filtering, in which case set query to
      # nil to avoid trailing '?' on the URL
      if new_params.size > 0
        @uri.query = new_params.map { |name, value | "#{name}=#{value}" }.join("&")
      else
        @uri.query = nil
      end
    end
  end

  class GoogleAnalytics < UrlFilter
    def filter
      filtered_params = params.reject do |name, value|
        name.start_with? "utm_"
      end
      update_params(filtered_params)

      uri
    end
  end

  class GUCE < UrlFilter
    def filter
      filtered_params = params.reject do |name, value|
        name.start_with?("guce_") || name == "guccounter"
      end
      update_params(filtered_params)

      uri
    end
  end

  FILTERS = [GoogleAnalytics, GUCE]

  def self.decruft(url)
    uri = URI(url)

    result = FILTERS.reduce(uri) { |uri, filter_class| filter_class.new(uri).filter }

    url.is_a?(String) ? result.to_s : result
  end
end