require "yaml"
require "http"
require "json"

class DiffHeight::Fetcher
  def initialize
    @lat_from, @lon_from = 54.79848, 13.56298
    @lat_to, @lon_to = 48.48495,24.65917

    @lat_diff = (@lat_to - @lat_from) as Float64
    @lon_diff = (@lon_to - @lon_from) as Float64

    @min_iteration = 2
    @max_iteration = 4

    @current_iteration = @min_iteration
    @x = 0
    @y = 0

    @resume_path = "resume.yml"
    @height_path = "height.csv"

    restore
  end

  def make_it_so
    while @current_iteration <= @max_iteration
      make_iteration

      increment_point
      store
    end
  end

  def make_iteration
    point = current_point
    url = "http://mapa.ump.waw.pl/ump-www/cgi/point_alt.cgi?lon=#{point[1]}&lat=#{point[0]}"

    response = HTTP::Client.get(url)
    json = JSON.parse(response.body.gsub("'", "\""))
    height = json[1][3]

    store_height(point[0], point[1], height)
  end

  def current_point
    r = [
      @lat_from + (@lat_diff * (@x.to_f / @current_iteration.to_f) ),
      @lon_from + (@lon_diff * (@y.to_f / @current_iteration.to_f) ),
    ]
    return r
  end

  def increment_point
    if @x >= @current_iteration
      @x = 0
      @y += 1

      if @y > @current_iteration
        @y = 0
        @current_iteration += 1
      end

    else
      @x += 1
    end
  end

  def current_state
    {
      "current_iteration": @current_iteration,
      "x": @x,
      "y": @y
    }
  end

  def store
    f = File.new(@resume_path, "w")
    f.puts(current_state.to_yaml)
    f.close
  end

  def restore
    if File.exists?(@resume_path)
      d = YAML.parse(File.read(@resume_path))
      @current_iteration = d["current_iteration"].to_s.to_i
      @x = d["x"].to_s.to_i
      @y = d["y"].to_s.to_i
    end
  end

  def store_height(lat, lon, height)
    f = File.new(@height_path, "a")
    f.puts("#{lat}, #{lon}, #{height}")
    f.close

    puts "#{lat},#{lon} - #{height}m"
  end
end
