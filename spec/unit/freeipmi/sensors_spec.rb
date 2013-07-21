require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
describe :Sensors do
  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    allow_message_expectations_on_nil
    data = nil
    provider = "freeipmi"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    # this stub allows us to mock the command that would be used to verify provider installation
    Rubyipmi.stub(:locate_command).with('ipmipower').and_return("#{@path}/ipmipower")

    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @sensors = @conn.sensors
    File.open("spec/fixtures/#{provider}/sensors.txt",'r') do |file|
      data = file.read
    end
    # this stub allows us to mock the command that is used with this test case
    @sensors.stub(:locate_command).with('ipmi-sensors').and_return('/usr/local/bin/ipmi-sensors')

    # these stubs allow us to run the command and return the fixtures
    @sensors.stub(:`).and_return(data)
    $?.stub(:success?).and_return(true)

  end

  it "cmd should be ipmi-sensors with four arguments" do
    @sensors.list
    verify_freeipmi_command(@sensors, 7, "#{@path}/ipmi-sensors")
  end



  it "can return a list of sensors" do
   @sensors.list.should_not be_nil
  end

  it "should return a count of sensors" do
    @sensors.count.should eq(29)
  end

  it "should return a list of fan names" do
    @sensors.fanlist.count.should eq(13)
  end

  it 'should return a list of temp names' do
    @sensors.templist.count.should.should eq(7)
  end

  it 'should return a list of sensor names as an array' do
    @sensors.names.should be_an_instance_of(Array)
    @sensors.names.count.should eq(29)
  end

  it 'should return an empty list if no data exists' do
    @sensors.stub(:getsensors).and_return(nil)
    @sensors.names.count.should eq(0)
  end

  it 'should return a sensor using method missing' do
    @sensors.names.each do |name|
      sensor = @sensors.send(name)
      sensor.should be_an_instance_of(Rubyipmi::Freeipmi::Sensor)
      sensor[:name].should eq(name)
    end
  end

  it "test should create new Sensor" do
      Rubyipmi::Freeipmi::Sensor.new("fakesensor").should_not be nil
  end


end
