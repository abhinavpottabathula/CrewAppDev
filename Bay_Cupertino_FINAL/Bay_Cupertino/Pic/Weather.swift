//
//  Weather.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/10/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import Foundation

struct Weather{
    let cityName: String
    let temp: Double
    let description: String
    let icon: String
    
    init(cityName: String,
        temp: Double,
        description: String,
        icon: String) {
            self.cityName = cityName
            self.temp = temp
            self.description = description
            self.icon = icon
    }

}