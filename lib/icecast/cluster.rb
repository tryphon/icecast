module Icecast
  class Cluster

    attr_reader :servers

    def initialize(*servers)
      @servers = servers.flatten
    end

    def ==(other)
      other and servers == other.servers
    end

    @@cache = NullCache.new
    cattr_accessor :cache

    def status_without_cache
      Status.new server_statuses
    end

    def server_statuses
      Parallel.map(servers, :in_threads => 4, &:status).compact
    end

    def status_with_cache
      cache.fetch("Icecast::Cluster::Status::#{cache_key}", :expires_in => 60, :race_condition_ttl => 5) do
        Icecast.logger.info "Retrieve Icecast cluster status"
        status_without_cache
      end
    end
    alias_method :status, :status_with_cache

    def cache_key
      servers.map(&:cache_key).sort.join('+')
    end

    class Status

      attr_reader :statuses

      def initialize(statuses)
        @statuses = statuses
      end

      def stream(mount_point)
        StreamStatus.new statuses.map { |s| s.stream mount_point }
      end

    end

    class StreamStatus

      attr_reader :stream_statuses

      def initialize(stream_statuses)
        @stream_statuses = stream_statuses
      end

      def started?
        stream_statuses.any? do |status|
          status.started?
        end
      end

      def listened
        stream_statuses.select do |status|
          status.listeners > 0
        end
      end

      def slave_count
        if listened.many? 
          listened.size - 1
        else
          0
        end
      end

      def listeners
        stream_statuses.map(&:listeners).sum - slave_count
      end

    end

  end
end
