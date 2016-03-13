require 'httparty'
require 'json'
require 'pry'

class GeoCodeJson

  GEOCODE_ENABLED = true

  LON_WEST_CENTER_CITY_BOUNDARY = -75.1804565
  LON_EAST_CENTER_CITY_BOUNDARY = -75.1393436
  # Spring Garden
  LAT_NORTH_CENTER_CITY_BOUNDARY = 39.9622624
  # Washington
  #LAT_SOUTH_CENTER_CITY_BOUNDARY = 39.9379171
  # Pine Street
  LAT_SOUTH_CENTER_CITY_BOUNDARY = 39.9469709

  LAT_PHILLY_CITY_HALL = 39.9526240
  LON_PHILLY_CITY_HALL = -75.1634620

  def initialize(mapquest_api_key, json_file, output_file)
    @mapquest_api_key = mapquest_api_key
    @json_file = json_file
    @output_file = output_file
  end

  def process()
    puts "process()"
    json = read_json
    add_geocode_to_json(json)
    sort_by_restaurant_name(json)
    write_as_json_to_file(json, @output_file, true)
  end

  private

  def read_json()
    @json ||= JSON.parse(File.read(@json_file))
  end

  def add_geocode_to_json(json)
    json.first['features'].each do |feature|
      restaurant_name = feature['properties']['restaurantName']
      puts "start - processing feature, #{feature['properties']['restaurantName']}"
      
      if GEOCODE_ENABLED && feature['geometry'].nil?
        lat, lon = geocode_address(restaurant_name, 
          feature['properties']['address'], feature['properties']['city'], feature['properties']['state'], feature['properties']['postalCode'])
        feature['geometry'] = {
          'type' => 'Point',
          'coordinates' => [lon, lat]
        }
      elsif feature['geometry']
        puts "Place for restaurant_name #{restaurant_name} already has existing lon/lat: #{feature['geometry']['coordinates'].inspect}"
      end
      puts "end - processing feature, #{feature['properties']['restaurantName']}"
    end
  end

  def geocode_address(restaurant_name, street_address, city, state, zip)
    address_line = [street_address, city, state, zip].join(' ')
    response = execute_http_call(geocode_request_url(address_line))
    return find_geocode_coordinates_in_center_city_boundaries(restaurant_name, response)
  end

  def find_geocode_coordinates_in_center_city_boundaries(restaurant_name, response)
    response.each_with_index do |place, index|
      # return first found in center city
      lat, lon = place['lat'].to_f, place['lon'].to_f
      return place['lat'].to_f, place['lon'].to_f if check_if_in_center_city_boundaries(restaurant_name, index, lat, lon)
    end
    # default response if no within center city address found
    puts "Place for restaurant_name #{restaurant_name} not found in center city boundaries!!"
    return LAT_PHILLY_CITY_HALL, LON_PHILLY_CITY_HALL
  end

  def geocode_request_url(address_line)
    "http://open.mapquestapi.com/nominatim/v1/search.php?key=#{@mapquest_api_key}&format=json&q=#{CGI.escape(address_line)}"
  end

  def sort_by_restaurant_name(json)
    json.first['features'].sort!{|aRestaurant, bRestaurant| aRestaurant['properties']['restaurantName'].downcase <=> bRestaurant['properties']['restaurantName'].downcase}
  end

  def check_if_in_center_city_boundaries(restaurant_name, index, lat, lon)
    if ((lon >= LON_WEST_CENTER_CITY_BOUNDARY)&&
        (lon <= LON_EAST_CENTER_CITY_BOUNDARY)&&
        (lat <= LAT_NORTH_CENTER_CITY_BOUNDARY)&&
        (lat >= LAT_SOUTH_CENTER_CITY_BOUNDARY))
      puts "Place for restaurant_name #{restaurant_name} found in center city boundaries at lat #{lat} and lon #{lon}. For index #{index} of results"
      return true
    else
      puts "Place for restaurant_name #{restaurant_name} with lat #{lat} and lon #{lon} is outside of center city boundaries! For index #{index} of results"
      return false
    end
  end

  def execute_http_call(url)
    begin
      response = HTTParty.get(url)
      JSON.parse(response.body)
    rescue Exception => e
      raise Exception.new("Failed to parse url!")
    end
  end

  def write_as_json_to_file(json_object, output_file_path, pretty_print=true)
    File.open(output_file_path, "w") do |f|
      if (!pretty_print)
        f.write(json_object.to_json)
      else
        f.write(JSON.pretty_generate(json_object))
      end
    end
  end

end

if ARGV.size == 3 && !ARGV[1].nil? && File.exists?(ARGV[1])
  GeoCodeJson.new(ARGV[0], ARGV[1], ARGV[2]).process
else
  puts "Execute as ruby geocodejson.rb <mapquest api key> <jsonwithoutgeocode.json> <output file.geojson>"
end
