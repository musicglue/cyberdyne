require 'spec_helper'

describe Cyberdyne::Doozer::Client do
  context "initializing a client with no parameters" do
    subject(:client) { build :doozer_client }
    
    context "configuration" do
      let(:config) { client.config }
      it "read_timeout" do
        config[:read_timeout].should eq(5)
      end
      it "connect_timeout" do
        config[:connect_timeout].should eq(3)
      end
      it "connect retry interval" do
        config[:connect_retry_interval].should eq(0.1)
      end
      it "connect retry count" do
        config[:connect_retry_count].should eq(3)
      end
      it "server" do
        config[:server].should eq("127.0.0.1:8046")
      end
      it "buffered" do
        config[:buffered].should eq(false)
      end
    end

    context "socket connection" do
      it "should create a ResilientSocket::TCPClient" do
        client.socket.should be_a(ResilientSocket::TCPClient)
      end
      it "should connect to a Doozerd Server" do
        client.socket.should be_alive
      end
      it "#close should close the socket" do
        client.socket.close
        client.socket.should_not be_alive
      end
    end 

  end

  context "initializing a custom client" do
    subject(:client) { build :complex_doozer_client }

    context "configuration" do
      let(:config) { client.config }
      it "read_timeout" do
        config[:read_timeout].should eq(10)
      end
      it "connect_timeout" do
        config[:connect_timeout].should eq(5)
      end
      it "connect retry interval" do
        config[:connect_retry_interval].should eq(1)
      end
      it "connect retry count" do
        config[:connect_retry_count].should eq(5)
      end
      it "server" do
        config[:server].should eq("localhost:8046")
      end
      it "buffered" do
        config[:buffered].should eq(false)
      end
    end
  end
end