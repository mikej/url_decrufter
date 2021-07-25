require "url_decrufter/version"

module UrlDecrufter
  def self.decruft(url)
    uri = URI(url)

    if uri.query.present?
      params = uri.query.split("&").map { |p| p.split("=") }
      filtered_params = params.reject do |name, value|
        name.starts_with? "utm_"
      end

      # may end up with 0 query params after filtering, in which case set query to
      # nil to avoid trailing '?' on the URL
      if filtered_params.size > 0
        uri.query = filtered_params.map { |name, value | "#{name}=#{value}" }.join("&")
      else
        uri.query = nil
      end
    end

    url.is_a?(String) ? uri.to_s : uri
  end
end
