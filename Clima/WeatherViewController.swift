//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation




	


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityViewDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    
    let locmang = CLLocationManager()
    var currWeaData : WeatherDataModel?

    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        
        locmang.delegate = self
        locmang.desiredAccuracy = kCLLocationAccuracyKilometer
        locmang.requestWhenInUseAuthorization()
        locmang.startUpdatingLocation()
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String) {
        print(url)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { (respuesta) in
            respuesta.result.ifSuccess{
                if let data =  respuesta.data{
               self.updateWeatherData(response: data)
            }
            }
    
            
            
        }
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(response: Data){
        let json = try! JSON(data: response)
        currWeaData = WeatherDataModel(ciudad: json["name"].stringValue, temp: json["main"]["temp"].doubleValue-273, condition: json["weather"][0]["id"].intValue)
      	print(json)
        print(currWeaData?.temp)
        updateUIWeatherData()
        
        
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWeatherData(){
        if let currcond = currWeaData?.condition, let currcity = currWeaData?.ciudad, let currtemp = currWeaData?.temp{
            if currtemp > -273{
            weatherIcon.image=UIImage(named:currcond)
            cityLabel.text=currcity
            let temperature = String(format: "%.1f", currtemp)+"º"
            temperatureLabel.text = temperature
            }
            
        }
      
        
        
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // print (locmang.location?.coordinate)
        let localitatio = locations[locations.count - 1]
         guard let location = locmang.location
            else {
                return
        }
       print(location)
        
        if localitatio.horizontalAccuracy > 0{
            locmang.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            let ulr = WEATHER_URL + "?lat=\(lat)&lon=\(long)&appid=\(APP_ID)"
            getWeatherData(url: ulr)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ha fallao")
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let ulr =  WEATHER_URL + "?q=\(city)&appid=\(APP_ID)"
        print(city)
        getWeatherData(url: ulr)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? ChangeCityViewController{
            destVC.delegate = self
        }
    }
    
    
    
    
    
}


