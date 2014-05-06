require "open_paths_converter"
require "stringio"

describe OpenPathsConverter do
  before(:each) do
    @open_paths_data = [
      { "lon" =>  -87.68896484375, "lat" =>  41.9178466796875 },
      { "lon" =>  -87.676185607910156, "lat" =>  41.914318084716797 },
      { "lon" =>  -87.705375671386719, "lat" =>  41.927906036376953 },
      { "lon" =>  -87.711692810058594, "lat" =>  41.930793762207031 }
    ].to_json
  end

  it "wraps everything in a feature collection" do
    convert(@open_paths_data)["type"].should == "FeatureCollection"
  end

  it "creates a feature for each piece of geo data" do
    convert(@open_paths_data)["features"].size.should == 4
  end

  it "creates a point conforming to the geojson declaration for each openpaths point" do
    convert(@open_paths_data)["features"].each_with_index do |point, idx|
      point["type"].should == "Feature"
      point["geometry"]["type"].should == "Point"
      point["geometry"]["coordinates"].size.should == 2
      point["properties"].should == {}
    end
  end

  it "adds a randomish offset to each coordinate" do
    fake_random_buffer = 0.05
    stub_const("OpenPathsConverter::OBFUSCATION_VALUE", fake_random_buffer)

    lon = -87.688
    lat = 41.9178
    paths = [{ "lon" => lon, "lat" => lat }]

    point = convert(paths.to_json)["features"].first
    point["geometry"]["coordinates"][0].should == lon + fake_random_buffer
    point["geometry"]["coordinates"][1].should == lat - fake_random_buffer
  end

  it "optionally writes the results to a specified file" do
    file = "tmp/paths.geojson"
    io = StringIO.new
    File.should_receive(:open).with(file, "w").and_yield(io)

    result = OpenPathsConverter.convert(@open_paths_data, file)
    io.string.should == result
  end

  def convert(json)
    JSON.parse(OpenPathsConverter.convert(json))
  end
end
