//
//  StockKit.swift
//  StockKit
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 7/22/17.
//

import Alamofire
import SwiftyJSON

public class Stock {
    
    public var json: JSON
    
    init(_ json: JSON) {
        self.json = json
    }
}

public struct StockKit {
    
    
    
    static func findQuoteInBackground(forSymbol symbol: String, completion: @escaping (Stock)->Void) {
        let url = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22\(symbol)%22)&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&format=json"
        
        Alamofire.request(url).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            let json = JSON(response.result.value ?? "")
            let quote = json["query"]["results"]["quote"]
            let stock = Stock(quote)
            completion(stock)
        }
    }
    
    static func findHistoricPricesInBackground(forSymbol symbol: String, beginAt: Date, completion: @escaping (Stock)->Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        
        let url = "https://quantprice.herokuapp.com/api/v1.1/scoop/period?tickers=\(symbol)&begin=\(dateFormatter.string(from: beginAt))"
        
        Alamofire.request(url).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            let json = JSON(response.result.value ?? "")
            let datatable = json["datatable"]
            let stock = Stock(datatable)
            completion(stock)
        }
    }
    
    static func findNewsInBackground(forSymbol symbol: String, completion: @escaping (Stock)->Void) {
        
        let url = "https://www.bloomberg.com/quote/\(symbol):us"
        
        Alamofire.request(url).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            let json = JSON(response.result.value ?? "")
            let datatable = json["datatable"]
            let stock = Stock(datatable)
            completion(stock)
        }
    }
}
