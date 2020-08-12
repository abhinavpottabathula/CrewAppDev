//
//  WeatherViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/10/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, WeatherServiceDelegate {

    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var temperatureLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var tipsLbl: UILabel!
    
    let weatherServ = WeatherService()
    
    @IBAction func setCityClicked(sender: AnyObject) {
        openCityAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.weatherServ.delegate = self
        temperatureLbl.text = ""
        descriptionLbl.text = ""
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openCityAlert(){
        let alert = UIAlertController(title: "Hello!", message: "Please enter the city you are in!", preferredStyle: UIAlertControllerStyle.Alert)
        
        let close = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(close)
        
        let submit = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
            let textField = alert.textFields?[0]
            let nameOfCity = textField?.text!
            self.cityLbl.text = nameOfCity
            self.weatherServ.getWeather(nameOfCity!)
        }
        alert.addAction(submit)

        alert.addTextFieldWithConfigurationHandler { (text:UITextField) -> Void in
            text.placeholder = "City Name..."
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func setWeather(weather:Weather) {
        
        let tempKelvin = weather.temp
        let tempF = (integer_t)((tempKelvin * (9.0 / 5.0)) - 459.67)
        
        temperatureLbl.text = "\(tempF)ºF"
        descriptionLbl.text = weather.description
        bgImg.image = UIImage(named: weather.icon)
        
        if(descriptionLbl.text!.isEmpty){
            cityLbl.text = "Oh no! Please enter a valid city."
        }else{
            cityLbl.text = weather.cityName
        }
        
        //add custom configuration
        
        if(tempF >= 100){
            tipsLbl.text = "Today seems to be pretty hot! Maybe it’s a good idea to avoid dark colors! Tip: Hot days are a great time to try a new look! Try loosening your collar and skipping the tie - shift to a more casual look!"
        }else if(tempF >= 80 && tempF < 100){
            tipsLbl.text = "Today seems to be a bit warmer than normal! Maybe it’s a good idea to avoid dark colors! Tip: While professional wear often calls for the traditional tie, a bowtie is a great twist on the plain look! It might help you feel more relaxed as well!"
        }else if(tempF >= 60 && tempF < 80){
            tipsLbl.text = "Today seems like a perfect day to dress your best! Try a new color with your tie, or  a different shirt with your coat! Warm days are the best times to shine out from the crowd!"
        }else if(tempF >= 45 && tempF < 60){
            tipsLbl.text = "Today might bring a little chill- Make sure to dress warmly! Consider wearing a thin shirt underneath your formal wear to help you keep warm!"
        }else{
            tipsLbl.text = "Today is likely to be pretty chilly! Make sure to dress warmly! Tip: Don’t think your formal wear is enough to withstand the cold? Consider sneaking in a scarf, and thick clothing under your coat! Wearing a scarf is a trendy way of keeping warm amidst the cold!"
        }
        
        //self.bgImg.image = //setImage
        
    }
    
    func weatherErrorWithMessage(message: String) {
        let alert = UIAlertController(title: "Weather Service Error", message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
