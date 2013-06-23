require 'spec_helper'

describe Icecast::Log do

  it "should parse valid lines" do
    lines = []
    Icecast::Log.new("spec/fixtures/access.log").each { |l| lines << l }
    lines.map(&:remote_ip).should == ["12.2.11.9", "78.115.170.50", "217.27.72.12"]
  end

end

describe Icecast::Log::Line do

  describe "#query=" do

    it "should transform query string in Hash" do
      subject.query = "arg1=value1&arg2=value2"
      subject.query.should == { "arg1" => ["value1"], "arg2" => ["value2"] }
    end

    it "should use a given Hash" do
      values = { "arg1" => ["value1"], "arg2" => ["value2"] }
      subject.query = values
      subject.query.should == values
    end

  end

  describe "#path=" do

    it "should define query when present in path" do
      subject.path = "/stream2.mp3?arg1=value1&arg2=value2"

      subject.path.should == "/stream2.mp3"
      subject.query.should == { "arg1" => ["value1"], "arg2" => ["value2"] }
    end

    it "should use given path" do
      subject.path = "/stream1.mp3"
      subject.path.should == "/stream1.mp3"
    end

  end

  describe "#started_at" do

    it "should should ended_at and duration" do
      subject.ended_at = Time.now
      subject.duration = 300

      subject.started_at.should == subject.ended_at - subject.duration
    end

  end

  describe ".parse" do

    context "a standard line" do

      let(:raw_line) do
        '17.27.72.12 - - [22/Jun/2013:09:40:57 +0200] "GET /stream2.mp3?arg1=value1&arg2=value2 HTTP/1.1" 200 188077545 "http://referer.com/path" "iTunes/11.0.4 (Windows; Microsoft Windows XP Home Edition Service Pack 3 (Build 2600)) AppleWebKit/536.30.1" 9705'
      end

      subject { Icecast::Log::Line.parse raw_line }

      it "should read remote ip" do
        subject.remote_ip.should == "17.27.72.12"
      end

      its(:username) { should be_nil }

      it "should read ended_at time" do
        subject.ended_at.should == Time.parse("22/Jun/2013 09:40:57 +0200")
      end

      it "should read method" do
        subject.method.should == "GET"
      end

      it "should read path" do
        subject.path.should == "/stream2.mp3"
      end

      it "should read query" do
        subject.query.should == { "arg1" => ["value1"], "arg2" => ["value2"] }
      end

      it "should read status code" do
        subject.status_code.should == 200
      end

      it "should read size" do
        subject.size.should == 188077545
      end

      it "should read referer" do
        subject.referer.should == "http://referer.com/path"
      end

      it "should read user agent" do
        subject.user_agent.should == "iTunes/11.0.4 (Windows; Microsoft Windows XP Home Edition Service Pack 3 (Build 2600)) AppleWebKit/536.30.1"
      end

      it "should read duration" do
        subject.duration.should == 9705
      end

    end

    context "a source line" do

      let(:raw_line) do
        '13.53.12.12 - source [19/Jun/2013:14:55:33 +0200] "SOURCE /stream1.mp3 ICE/1.0" 200 8047803 "-" "-" 514'
      end

      subject { Icecast::Log::Line.parse raw_line }

      it "should read username" do
        subject.username.should == "source"
      end

      its(:method) { should == "SOURCE" }

    end

  end

end
