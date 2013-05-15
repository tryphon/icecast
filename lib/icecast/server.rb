require 'httparty'

module Icecast
  class Server
    include HTTParty
    format :xml
    
    attr_accessor :host, :port, :admin_password

    def initialize(attributes = {})
      attributes = { :port => 8000 }.merge(attributes)

      attributes.each do |k,v|
        send "#{k}=", v
      end
    end

    def ==(other)
      other and host == other.host and port == other.port
    end

    def url_for(path)
      "http://#{host}:#{port}/#{path}"
    end

    def authentification
      { :username => 'admin', :password => admin_password }
    end

    @@cache = NullCache.new
    cattr_accessor :cache

    def xml_status
      cache.fetch("Icecast::Status::#{cache_key}", :expires_in => 60, :race_condition_ttl => 5) do
        Icecast.logger.info "Retrieve Icecast status from #{host}"
        self.class.get url_for("admin/stats"), :basic_auth => authentification
      end
    end

    def cache_key
      "#{host}_#{port}"
    end

    def status!
      Status.new xml_status
    end

    def status
      status! 
    rescue Exception => e
      Icecast.logger.error "Can't retrieve status on #{host} : #{e}"
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
