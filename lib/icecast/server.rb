require 'httparty'

module Icecast
  class Server
    include HTTParty
    format :xml
    
    attr_accessor :host, :port, :admin_password

    def initialize(attributes = {})
      attributes.each do |k,v|
        send "#{k}=", v
      end
    end

    def url_for(path)
      "http://#{host}:8000/#{path}"
    end

    def authentification
      { :username => 'admin', :password => admin_password }
    end

    class NullCache

      def fetch(*arguments, &block)
        yield
      end

    end

    def self.default_cache
      defined?(Rails) ? Rails.cache : NullCache.new
    end

    @@cache = default_cache
    cattr_accessor :cache

    def xml_status
      cache.fetch("Icecast::Status::#{host}_#{port}", :expires_in => 60, :race_condition_ttl => 5) do
        Icecast.logger.info "Retrieve Icecast status from #{host}"
        self.class.get url_for("admin/stats"), :basic_auth => authentification
      end
    end

    def status
      Status.new xml_status
    end

    class Status

      attr_accessor :parsed_status, :created_at

      def initialize(parsed_status)
        @created_at = Time.now
        @parsed_status = parsed_status
        @stream_statuses = {}
      end

      def parsed_source_statuses
        sources = parsed_status["icestats"]["source"]
        Hash === sources ? [sources] : Array(sources)
      end

      def stream(mount_point)
        mount_point = "/#{mount_point}" unless mount_point.start_with?("/")
        @stream_statuses[mount_point] ||= 
          begin
            parsed_source_status = parsed_source_statuses.find { |s| s["mount"] == mount_point }
            StreamStatus.new(parsed_source_status)
          end
      end

      def location
        parsed_status["icestats"]["location"]
      end

    end

    class StreamStatus

      attr_accessor :parsed_status

      def initialize(parsed_status)
        @parsed_status = parsed_status
      end

      def started?
        parsed_status.present?
      end

      def listeners
        started? ? parsed_status["listeners"].to_i : 0
      end
      
    end

  end
end
