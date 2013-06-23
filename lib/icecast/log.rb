require 'iconv'

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

    attr_accessor :file

    def initialize(file)
      @file = file
    end

    def each(&block)
      File.open(file, "r").each_line do |line|
        if log_line = Line.parse(line)
          yield log_line
        end
      end
    end

    class TimeWriter < Virtus::Attribute::Writer::Coercible
      def coerce(value)
        (value.nil? or value.is_a?(Time)) ? value : Time.strptime(value, "%d/%b/%Y:%H:%M:%S %z")
      end
    end

    class QueryWriter < Virtus::Attribute::Writer::Coercible
      def coerce(value)
        (value.nil? or value.is_a?(Hash)) ? value : CGI::parse(value)
      end
    end

    class Line
      include Virtus

      attribute :remote_ip, String
      attribute :username, String
      attribute :started_at, Time, :writer_class => TimeWriter
      attribute :path, String
      attribute :method, String
      attribute :query, Hash, :writer_class => QueryWriter
      attribute :status_code, Integer
      attribute :size, Integer
      attribute :referer, String
      attribute :user_agent, String
      attribute :duration, Integer

      def self.fix_encoding(line)
        ::Iconv.conv 'UTF-8//IGNORE', 'UTF-8', line
      end

      def username=(username)
        @username = (username == "-" ? nil : username)
      end

      def referer=(referer)
        @referer = (referer == "-" ? nil : referer)
      end

      def path=(path)
        if path =~ /(.*)\?(.*)/
          path = $1
          self.query = $2
        end
        @path = path
      end


      def self.parse(line)
        line = fix_encoding line

        if line =~ %r{^([0-9\.]+) - ([^ ]+) \[([^\]]+)\] "(GET|HEAD|SOURCE) ([^ ]+) (HTTP|ICE)/1.[01x]" ([0-9]+) ([0-9]+) "([^"]+)" "([^"]+)" ([0-9]+)$}
          new :remote_ip => $1, :username => $2, :started_at => $3, :method => $4, :path => $5, :status_code => $7, :size => $8, :referer => $9, :user_agent => $10, :duration => $11
        end
      end

    end
  end
end
