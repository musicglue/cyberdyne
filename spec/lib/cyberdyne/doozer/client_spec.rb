require 'spec_helper'

describe Cyberdyne::Doozer::Client do
  context "initializing a client with no parameters" do
    subject(:client) { build :doozer_client }
    
    context "configuration" do
      let(:config) { client.config }
      it "read_timeout" do
        config[:read_timeout].should eq(0.1)
      end
      it "connect_timeout" do
        config[:connect_timeout].should eq(0.1)
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

  context "socket connection" do
    subject(:client) { build :doozer_client }
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

  describe "commands" do
    subject(:client) { build :doozer_client }
    context "presence" do
      it { should respond_to(:invoke) }
      it { should respond_to(:send) }
      it { should respond_to(:read) }
      it { should respond_to(:current_revision) }
      it { should respond_to(:[]) }
      it { should respond_to(:[]=) }
      it { should respond_to(:get) }
      it { should respond_to(:set) }
    end

    context "protected methods" do
      context '#invoke' do
        let(:request)     { build :rev_request }
        it "should error if not provided a valid Request object" do
          expect {
            client.__send__(:invoke, nil)
          }.to raise_error(ArgumentError)
        end
      end

      context "#send" do
        it "should raise an error if not provided a valid Request object" do
          expect {
            client.__send__(:send, nil)
          }.to raise_error(ArgumentError)
        end
      end

      context "#read" do
        context "without a request being made" do
          it "should raise an error if there is nothing to read"  do
            expect {
              client.__send__(:read)
            }.to raise_error(ResilientSocket::ReadTimeout)
          end
        end
      end
    end

    context "public api" do
      it "returns the current_revision" do
        client.current_revision.should be_a(Fixnum)
      end

      it "sets and retrieves values in Doozer" do
        rev = client.set("/test/foo", "bar")
        result = client.get("/test/foo")
        result.value.should eq("bar")
        result.rev.should eq(rev)
      end

      it "gets and sets values through [] getter/setter" do
        client['/test/foo'] = "baz"
        result = client['/test/foo']
        result.should eq("baz")
      end

      it "should fetch directories in a path" do
        @path = "/test"
        client['/test/foo'] = "bar"
        client['/test/bar'] = "baz"
        count = 0
        until client.directory(@path, count).nil?
          count += 1
        end
        count.should be > 0
      end

      it "should walk a given path set" do
        client.walk("/test/*").sort.should eq(["bar", "baz"].sort)
      end

      it "should delete keys" do
        client['/test/foo'] = "bar"
        client.delete("/test/foo")
        client['/test/foo'].should be_empty
      end

      it "returns the current stats for a path" do
        client.delete '/test/foo'
        client['/test/foo'] = "baz"
        client.stat("/test/foo").rev.should eq(client.current_revision)
      end

      it "should access a path" do
        client.delete '/test/foo'
        client['/test/foo'] = "baz"
        client.access("/test/foo").tag.should eq(0)
      end
    end

    context "doozerd instances" do
      it "should return an array of hosts" do
        client.doozer_hosts.should eq(["127.0.0.1:8046"])
      end
    end

    context "timed operations" do
      it "should wait for the next change to a key" do
        @test = nil
        thr = Thread.new do
          @test = client.wait("/test/foo")
        end
        thr.wakeup
        sleep 0.01
        client['/test/foo'] = "baz"
        @test.should_not eq("baz")

        thr.kill
      end

      it "should watch a key and return changes to it" do
        client2 = build :doozer_client
        @test, @running = nil, true
        mtx = Mutex.new
        cd = ConditionVariable.new
                
        thr = Thread.new do
          client.watch("/test/foo") do |result|
            mtx.synchronize do
              @test = result.value
              cd.signal if result.value =~ /bar/
              sleep 0.01
            end
          end
        end

        thr.run
        sleep 0.01
        
        mtx.synchronize do
          client2["/test/foo"] = "bar"
          cd.wait(mtx)
          @test.should eq("bar")
          thr.kill
        end

      end
    end
  end
end







