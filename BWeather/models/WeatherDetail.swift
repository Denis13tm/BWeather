//
//  WeatherDetail.swift
//  BWeather
//

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE"
    return dateFormatter
}()

private let hourFormatter: DateFormatter = {
    let hourFormatter = DateFormatter()
    hourFormatter.dateFormat = "ha"
    return hourFormatter
}()


struct DailyWeather {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

struct HourlyWeather {
    var hour: String
    var hourlyTemperature: Int
    var hourlyIcon: String
}

class WeatherDetail: WeatherLocation {
    
    
    struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
        var hourly: [Hourly]
    }
    
    struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    struct Weather: Codable {
        var description: String
        var icon: String
    }
    
    struct Daily: Codable { //Codable <- For JSON parsing
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
    }
    
    struct Hourly: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    struct Temp: Codable {
        var max: Double
        var min: Double
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dayIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    var hourlyWeatherData: [HourlyWeather] = []
    
    func getData(completed: @escaping () ->() ) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=imperial&appid=\(APIkeys.openWeatherKey)"
        
        //Create URL
        guard let url = URL(string: urlString) else {
            print("EROR: Could not create a URL from \(urlString)")
            completed()
            return
        }
        
        //Create Session
        let session = URLSession.shared
        
        //get data with .dataTask method
        let task = session.dataTask(with: url) {(data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
        
            //note: blablabla...
            
            //deal with the data
            do {
                let result = try JSONDecoder().decode(Result.self, from: data!)
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
                self.dayIcon = self.fileNameForIcon(icon: result.current.weather[0].icon)
                
                for index in 0..<result.daily.count {
                    let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let dailyWeekday = dateFormatter.string(from: weekdayDate)
                    
                    let dailyIcon = self.fileNameForIcon(icon: result.daily[index].weather[0].icon)
                    let dailySummer = result.daily[index].weather[0].description
                    let dailyHigh = Int(result.daily[index].temp.max.rounded())
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummer, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                }
                //Get no more than 24 hours hourly data
                let lastHour = min(24, result.daily.count)
                if lastHour > 0 {
                    for index in 1...lastHour {
                        let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                        hourFormatter.timeZone = TimeZone(identifier: result.timezone)
                        let hour = hourFormatter.string(from: hourlyDate)
                        let hourlyIcon = self.fileNameForIcon(icon: result.hourly[index].weather[0].icon)
                        let hourlyTemperature = Int(result.hourly[index].temp.rounded())
                        let hourlyWeather = HourlyWeather(hour: hour, hourlyTemperature: hourlyTemperature, hourlyIcon: hourlyIcon)
                        self.hourlyWeatherData.append(hourlyWeather)
                    }
                }
                
            } catch {
                print(":( JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
    
    private func fileNameForIcon(icon: String) -> String {
        var newFileName = ""
        switch icon {
        case "01d":
            newFileName = "1.clear sky"
        case "01n":
            newFileName = "1.n clear sky"
        case "02d":
            newFileName = "2.few clouds"
        case "02n":
            newFileName = "2.n few clouds"
        case "03d":
            newFileName = "3.scattered clouds"
        case "03n":
            newFileName = "3.n scattered clouds"
        case "04d":
            newFileName = "4.broken clouds"
        case "04n":
            newFileName = "4.n broken clouds"
        case "09d":
            newFileName = "09.shower rain"
        case "09n":
            newFileName = "09.n shower rain"
        case "10d":
            newFileName = "10.rain"
        case "10n":
            newFileName = "10.n rain"
        case "11d":
            newFileName = "11.d thunderstorm"
        case "11n":
            newFileName = "11.n thunderstorm"
        case "13d":
            newFileName = "13.snow"
        case "13n":
            newFileName = "13.n snow"
        case "50d", "50n":
            newFileName = "50.mist"
        default:
            newFileName = ""
        }
        
        return newFileName
    }
    
}
