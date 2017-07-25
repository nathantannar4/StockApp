//
//  ViewController.swift
//  StockKit
//
//  Created by Nathan Tannar on 7/20/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import SwiftChart

class ViewController: UIViewController {
    
    var chart: Chart = {
        let chart = Chart()
        return chart
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.frame = CGRect(x: 0, y: 20, width: view.bounds.width, height: 300)
        view.addSubview(chart)
        view.backgroundColor = .white
        
        StockKit.findQuoteInBackground(forSymbol: "AAPL") { (stock) in
            print(stock.json)
        }
        
        StockKit.findHistoricPricesInBackground(forSymbol: "AAPL", beginAt: Date.fromString(strDate: "2016-01-01", format: "YYYY-MM-DD")!) { (stock) in
            print(stock.json)
            
            let dates = stock.json["data"].array?.map({ (json) -> Date in
                let dateString = json.array?[6].stringValue
                return Date.fromString(strDate: dateString!, format: "YYYY-MM-DD")!
            })
            let closes = stock.json["data"].array?.map({ (json) -> Float in
                let close = json.array?[10].floatValue
                return close!
            })
            let chartSeries = ChartSeries(closes!)
            self.chart.add(chartSeries)
            
        }
    }
}

