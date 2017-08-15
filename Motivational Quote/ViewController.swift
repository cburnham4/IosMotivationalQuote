//
//  ViewController.swift
//  Motivational Quote
//
//  Created by Chase on 5/6/17.
//  Copyright © 2017 LetsHangLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import GoogleMobileAds

import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    /* Views */
    @IBOutlet weak var QuoteLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var timeTextField: UITextField!

    /* Data */
    var quotes = [String]()
    var minutes: Int = 0
    var hour: Int = 8

    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Cancel all previous notifications */
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let defaults = UserDefaults.standard
        if let date = defaults.object(forKey: "Date"){
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short
            let calendar = Calendar.current
            
            self.hour = calendar.component(.hour, from: date as! Date)
            self.minutes = calendar.component(.minute, from: date as! Date)
            timeTextField.text = dateFormatter.string(from: date as! Date)
            
        }
        
        getQuotes()
        //loadNewQuote()
   }
    
    func getQuotes(){
        let defaults = UserDefaults.standard
        if let stringOne = defaults.stringArray(forKey: "Quotes") {
            print("Quotes saved")
            self.quotes = stringOne
            loadNewQuote()
            initNotificationSetupCheck()
        }else{
            print("Request quotes ")
            /* get quotes if not already on device */
            APIRequests.getQuotes(callback: getQuotesCallback(success:))
        }
    }
    
    func getQuotesCallback(success: Bool){
        print("Got quotes")
        if(success){
            /* Store quotes */
            let defaults = UserDefaults.standard
            defaults.set(APIRequests.quotes, forKey: "Quotes")
            self.quotes = APIRequests.quotes
            loadNewQuote()
            initNotificationSetupCheck()
        }
    }
    
    func getQuote() -> String{
        let n = Int(arc4random_uniform(UInt32(quotes.count)))

        return quotes[n]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        loadNewQuote()
    }
    
    func createNotification(){
        print("Create notification")
        //add notification code here
        
        if #available(iOS 10.0, *) {
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Daily Motivation"
            //content.subtitle = "From MakeAppPie.com"
            content.body = "Click here to check out the quote of the day"
            
            //Set the trigger of the notification -- here a timer.
//            let trigger = UNTimeIntervalNotificationTrigger(
//                timeInterval: 60.0,
//                repeats: true)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: self.hour  , minute:self.minutes), repeats: true)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "quoteMessage",
                content: content,
                trigger: trigger
            )
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
            
        
        
        }
        

    }
    
    func loadNewQuote(){
        let n = Int(arc4random_uniform(UInt32(quotes.count)))
        
        
        QuoteLabel.text = quotes[n]
    }
    
    
    func initNotificationSetupCheck() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            { (success, error) in
                if success {
                    print("Permission Granted")
                    self.createNotification()
                } else {
                    print("There was a problem!")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

//    func requestQuote(){
//        print("Requesting quote")
//        let url: String = "https://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=en"
//        
//        Alamofire.request(url, method: .get).validate().responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                print("JSON: \(json)")
//                let quote = json["quoteText"].stringValue
//                let author = json["quoteAuthor"].stringValue
//                
//                self.updateQuote(quote: quote, author: author)
//            case .failure(let error):
//                print(error)
//                self.requestQuote()
//            }
//        }
//        
//    }
    
    func updateQuote(quote: String, author: String){
        var newText = ""
        if(author.isEmpty){
            newText = quote
        }else{
            newText = quote + "\n -" + author
        }
        
        QuoteLabel.text = newText
    }
    
    func loadAd(){
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        
        let request = GADRequest()
        //request.testDevices = ["a0059a5e61136be10d2e720167aa8c96"]
        
        bannerView.adUnitID = "ca-app-pub-8223005482588566/3723198739"
        bannerView.rootViewController = self
        bannerView.load(request)
    }

    @IBAction func pickTime(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.time
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(ViewController.udpateAlarmTime), for: UIControlEvents.valueChanged)
    }

    func udpateAlarmTime(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let calendar = Calendar.current
        
        let date = sender.date
        self.hour = calendar.component(.hour, from: date)
        self.minutes = calendar.component(.minute, from: date)
        
        timeTextField.text = dateFormatter.string(from: sender.date)
        
        print("Create notification at " + hour.description + " " + minutes.description)
        
        /* Save date */
        let defaults = UserDefaults.standard
        defaults.set(date, forKey: "Date")
        
        createNotification()
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    @IBAction func requestNewQuote(_ sender: UIButton) {
//        requestQuote()
//    }

}

