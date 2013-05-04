require 'spec_helper'

describe Icecast::Server do

  let(:host) { "stream.tryphon.priv" }
  subject { Icecast::Server.new :host => host, :admin_password => "dummy" }

  describe "#url_for" do
    
    it "should use host, port and given path" do
      subject.host = "server"
      subject.port = 123
      subject.url_for("dummy").should == "http://server:123/dummy"
    end

  end

  describe "status" do

    let(:stats_body) { IO.read "spec/fixtures/icecast_admin_stats.xml" }

    before(:each) do
      FakeWeb.register_uri :get, "http://admin:dummy@#{host}:8000/admin/stats", :body => stats_body
    end
    
    it "should use xml information retrieved in admin/stats" do
      subject.status.location.should == "RSpec"
    end

    it "should find stream statuses for each mount point" do
      subject.status.stream("48FM.mp3").listeners.should == 4
      subject.status.stream("live.mp3").listeners.should == 7
      subject.status.stream("live.ogg").listeners.should == 14
    end

  end

end
