require "json"
require "date"

module OpenPathsConverter
  OBFUSCATION_VALUE = 0

  class << self
    def convert(json, file = nil)
      geojson = convert_to_geojson_point_collection(JSON.parse(json))
      write_to_file!(file, geojson) unless file.nil?
      geojson
    end

    def write_to_file!(file, geojson)
      File.open(file, "w") do |io|
        io.write(geojson)
      end
    end

    def convert_to_geojson_point_collection(paths)
      geojson = { type: "FeatureCollection", features: [] }
      geojson[:features] = paths.map { |path| create_point(path) }
      geojson.to_json
    end

    def create_point(coordinates)
      {
        type: "Feature",
        geometry: {
          type: "Point",
          coordinates: obfuscate_coordinates(coordinates)
        },
        properties: {
          day: Time.at(coordinates["t"]).to_date.to_s
        }
      }
    end

    def obfuscate_coordinates(coordinates)
      [(coordinates["lon"] + OBFUSCATION_VALUE), (coordinates["lat"] - OBFUSCATION_VALUE)]
    end
  end
end

