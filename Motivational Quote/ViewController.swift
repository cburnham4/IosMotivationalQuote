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

class ViewController: UIViewController {

    /* Views */
    @IBOutlet weak var QuoteLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        requestQuote()
        loadAd()
    }

    func requestQuote(){
        print("Requesting quote")
        let url: String = "https://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=en"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                let quote = json["quoteText"].stringValue
                let author = json["quoteAuthor"].stringValue
                
                self.updateQuote(quote: quote, author: author)
            case .failure(let error):
                print(error)
                self.requestQuote()
            }
        }
    }
    
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

    @IBAction func requestNewQuote(_ sender: Any) {
        requestQuote()
    }

}

