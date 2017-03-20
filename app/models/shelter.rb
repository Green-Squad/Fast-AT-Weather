class Shelter < ApplicationRecord
  has_many :weathers
  belongs_to :state

  def next
    self.class.where("mileage > ?", mileage).first
  end

  def previous
    self.class.where("mileage < ?", mileage).last
  end

  def load_weather(type)
    base_url = 'http://api.openweathermap.org/data/2.5/forecast'
    if type == 'daily'
      base_url += '/daily?'
    elsif type == 'hourly'
      base_url += '?'
    end
    api_key = '&appid=' + ENV['OPEN_WEATHER_MAP_API_KEY']
    units = '&units=imperial'
    request_url = base_url + "lat=#{self.latt}&lon=#{self.long}" + units + api_key
    JSON.load(open(request_url))
  end

  def update_weather
    Weather.where(shelter: self).delete_all

    forecast = load_weather('daily')

    forecast['list'].each do |weather|
      weather_date = DateTime.strptime("#{weather['dt']}",'%s')
      high = weather['temp']['max']
      low = weather ['temp']['min']
      description = weather['weather'][0]['description']
      wind_direction = weather['deg']
      wind_speed = weather['speed']

      description += " Wind: #{wind_speed} m/s at #{wind_direction} degrees"
      Weather.create(weather_date: weather_date, high: high, low: low,
        description: description, precip_chance:0, shelter:self)
    end
  end

  def update_hourly_weather
    HourlyWeather.where(shelter: self).delete_all

    forecast = load_weather('hourly')

    forecast['list'].each do |weather|
      date = DateTime.strptime("#{weather['dt']}",'%s')
      temp = weather['main']['temp']
      description = weather['weather'][0]['description']
      wind_direction = weather['wind']['deg']
      wind_speed = weather['wind']['speed']

      description += " Wind: #{wind_speed} m/s at #{wind_direction} degrees"
      HourlyWeather.create(date: date, temp: temp,
        description: description, precip_chance:0, shelter:self)
    end
  end

end
