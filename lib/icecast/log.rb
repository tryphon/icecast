class Time
  # Requires for Ruby 1.8
  def self.strptime(date, format, now=self.now)
    d = Date._strptime(date, format)
    raise ArgumentError, "invalid strptime format - `#{format}'" unless d
    if seconds = d[:seconds]
      Time.at(seconds)
    else
      year = d[:year]
      year = yield(year) if year && block_given?
      make_time(year, d[:mon], d[:mday], d[:hour], d[:min], d[:sec], d[:sec_fraction], d[:zone], now)
    end
  end unless respond_to?(:strptime)
end

module Icecast

  class Log

    attr_accessor :file, :seek

    def initialize(file)
      @file = file
    end

    include Enumerable

    def each(&block)
      File.open(file, "r") do |f|
        f.seek seek, IO::SEEK_SET if seek
        f.each_line do |line|
          if log_line = Line.parse(line)
            yield log_line
          end
        end
      end
    end

    class Time < Virtus::Attribute
      def coerce(value)
        (value.nil? or value.is_a?(::Time)) ? value : ::Time.strptime(value, "%d/%b/%Y:%H:%M:%S %z")
      end
    end

    class Query < Virtus::Attribute
      def coerce(value)
        (value.nil? or value.is_a?(::Hash)) ? value : CGI::parse(value)
      end
    end

    class Line
      include Virtus.model

      attribute :remote_ip, String
      attribute :username, String
      attribute :ended_at, Time
      attribute :path, String
      attribute :method, String
      attribute :query, Query
      attribute :status_code, Integer
      attribute :size, Integer
      attribute :referer, String
      attribute :user_agent, String
      attribute :duration, Integer

      def self.fix_encoding(line)
        if line.respond_to?(:encode)
          line.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
        else
          require 'iconv'
          ::Iconv.conv 'UTF-8//IGNORE', 'UTF-8', line
        end
      end

      def username=(username)
        @username = (username == "-" ? nil : username)
      end

      def referer=(referer)
        @referer = (referer == "-" ? nil : referer)
      end

      def user_agent=(user_agent)
        @user_agent = (user_agent == "-" ? nil : user_agent)
      end

      def path=(path)
        if path =~ /(.*)\?(.*)/
          path = $1
          self.query = $2
        end
        @path = path
      end

      def started_at
        ended_at - duration if ended_at and duration
      end

      def self.parse(line)
        line = fix_encoding line

        if line =~ %r{^([0-9\.]+) - ([^ ]+) \[([^\]]+)\] "(GET|HEAD|SOURCE) ([^ ]+) (HTTP|ICE)/1.[01x]" ([0-9]+) ([0-9]+) "([^"]+)" "([^"]+)" ([0-9]+)$}
          new :remote_ip => $1, :username => $2, :ended_at => $3, :method => $4, :path => $5, :status_code => $7, :size => $8, :referer => $9, :user_agent => $10, :duration => $11
        end
      end

    end
  end
end
