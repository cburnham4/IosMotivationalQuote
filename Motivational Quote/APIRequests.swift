//
//  APIRequests.swift
//  Motivational Quote
//
//  Created by Carl Burnham on 8/7/17.
//  Copyright © 2017 LetsHangLLC. All rights reserved.
//

import Foundation
import FirebaseDatabase

class APIRequests{
 
    static var quotes = [String]()
    
    static func getQuotes(callback: @escaping (_ success: Bool) -> ()){
        let ref = Database.database().reference().child("Quotes")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childrenCount.description)
            
            let children = snapshot.children
            
            // Get user value
            while let dataSnap = children.nextObject() as? DataSnapshot{
                
                let author = dataSnap.key
                let quote = dataSnap.value as! String
                
                if(author != "dateCreated"){
                    print(dataSnap.key)
                    let completeQuote = quote + "\n -" + author
                    quotes.append(completeQuote)
                }
                
            }
            print(snapshot.childrenCount.description)
            DispatchQueue.main.async(execute: {
                callback(true)
            })
            
            
        }) { (error) in
            print("Error" +  error.localizedDescription)
            DispatchQueue.main.async(execute: {
                callback(false)
            })
            
        }
        print("Try to get quotes")
        

    }
}
