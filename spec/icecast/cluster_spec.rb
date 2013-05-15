require 'spec_helper'

describe Icecast::Cluster do

  let(:master_server) { mock "first server", :status => mock("first status"), :cache_key => "first" }
  let(:slave_server) { mock "second server", :status => mock("second status"), :cache_key => "second" }

  subject { Icecast::Cluster.new master_server, slave_server }

  def fake_stream(server, stream, attributes = {})
    server.status.stub(:stream).with(stream).and_return(mock(attributes))
  end

  describe "stream listeners" do
    
    it "should sum stream listeners without slave connections" do
      fake_stream master_server, "dummy", :listeners => 5
      fake_stream slave_server, "dummy", :listeners => 4

      subject.status.stream("dummy").listeners.should == 8
    end

    it "should ignore slaves with zero listeners" do
      fake_stream master_server, "dummy", :listeners => 5
      fake_stream slave_server, "dummy", :listeners => 0

      subject.status.stream("dummy").listeners.should == 5
    end

  end
  
  describe "stream started?" do

    it "should be false when all server return false" do
      fake_stream master_server, "dummy", :started? => false
      fake_stream slave_server, "dummy", :started? => false

      subject.status.stream("dummy").should_not be_started
    end

    it "should be true if any server returns started" do
      fake_stream master_server, "dummy", :started? => true
      fake_stream slave_server, "dummy", :started? => false

      subject.status.stream("dummy").should be_started
    end
    
  end

  describe "#cache_key" do
    
    it "should contact servers cache_keys" do
      subject.cache_key.should == "first+second"
    end

  end

end
