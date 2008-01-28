$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../../lib"))

require 'java'
require 'monkeybars/view'
require 'monkeybars/controller'
require 'spec/unit/test_files.jar'

class TestingView < Monkeybars::View
  set_java_class 'org.monkeybars.TestView'  
end

describe "view's get_field_value method" do
  before(:each) do
    @view = TestingView.new
  end

  after(:each) do
    #Make swing threads go away so test can exit
    @view.instance_variable_get("@main_view_component").dispose
  end
  
  it "should return a reference to the java field's value" do
    @view.send(:get_field_value, :test_label).text.should == "A Test Label"
    @view.send(:get_field_value, :test_label).text = "New Label"
    @view.send(:get_field_value, :test_label).text.should == "New Label"
  end
  
  it "can return a reference to a primitive field" do
    @view.send(:get_field_value, :primitive_variable).should == 20
    @view.send(:get_field_value, :object_variable).should == 30
  end
  
  it "returns same reference on subsequent calls" do
    
    label = @view.send(:get_field_value, :test_label)
    label2 = @view.send(:get_field_value, :test_label)
    label.should equal(label2)
  end
end

describe "view's get_field method" do
  it "uses cached reference to a field if it is available" do
    view = TestingView.new
    view.instance_variable_get(:@__field_references)[:test_label] = "test data that replaces actual field"
    view.send(:get_field, :test_label).should == "test data that replaces actual field"
    view.instance_variable_get("@main_view_component").dispose
  end
end

describe "view's add_handler method" do
  it "can resolve nested components" do
    view = TestingView.new
    lambda {view.add_handler(:document, Monkeybars::DocumentHandler.new(self), "testTextField.some_made_up_name")}.should raise_error(NoMethodError)
    lambda {view.add_handler(:document, Monkeybars::DocumentHandler.new(self), "testTextField.document")}.should_not raise_error(NoMethodError)
    
    view.instance_variable_get("@main_view_component").dispose
  end
end

describe "view's validate_mapping method" do
  it "identifies mappings as in-only, out-only, or bi-directional"
  it "detects mis-named methods declared in a mapping"
end

describe "view's write_state method" do
  it "only invokes mappings with direction to view or both" do
    class TestView < Monkeybars::View; end
    view = TestView.new

    mock_mappings = Array.new(5) { |i| mock("Mapping#{i}", :from_view => nil)}
    mock_mappings[0].should_receive(:maps_from_view?).and_return(true)
    mock_mappings[0].should_receive(:from_view).once
    mock_mappings[1].should_receive(:maps_from_view?).and_return(true)
    mock_mappings[1].should_receive(:from_view).once
    mock_mappings[2].should_receive(:maps_from_view?).and_return(false)
    mock_mappings[2].should_not_receive(:from_view)
    mock_mappings[3].should_receive(:maps_from_view?).and_return(false)
    mock_mappings[3].should_not_receive(:from_view)
    mock_mappings[4].should_receive(:maps_from_view?).and_return(false)
    mock_mappings[4].should_not_receive(:from_view)
    
    TestView.should_receive(:view_mappings).and_return(mock_mappings)
    
    view.write_state(nil, {})
  end
end