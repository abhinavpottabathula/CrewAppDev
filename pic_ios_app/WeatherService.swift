//
//  WeatherService.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/10/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import Foundation

protocol WeatherServiceDelegate{
    func setWeather(weather:Weather)
}

class WeatherService{
    
    var delegate: WeatherServiceDelegate?
    
    func getWeather(city:String){
        
        let cityEsc = city.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        
        let path : String = "http://api.openweathermap.org/data/2.5/weather?q=\(cityEsc!)&appid=44db6a862fba0b067b1930da0d769e98"
        let url : NSURL = NSURL(string: path)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            var status = 0
            
            let json = JSON(data: data!)
            
            if let cod = json["cod"].int {
                status = cod
            } else if let cod = json["cod"].string {
                status = Int(cod)!
            }
            
            if status == 200{
                let lon = json["coord"]["lon"].double
                let lat = json["coord"]["lat"].double
                let temperature = json["main"]["temp"].double
                let name = json["name"].string
                let description = json["weather"][0]["description"].string
                let myIcon = json["weather"][0]["icon"].string
                
                let weather = Weather(cityName: name!, temp: temperature!, description: description!, icon: myIcon!)
            
                if self.delegate != nil{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.setWeather(weather)
                    })
                }
            }else if status == 404 {
                // City not found
                
            }else {
               
            }
            
        }
        
        task.resume()
    }
}