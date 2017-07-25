//
//  StockTrackerViewController.swift
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
//  Created by Nathan Tannar on 7/23/17.
//

import NTComponents
import SwiftChart

open class StockTrackerViewController: NTCollectionViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        makeLargeTitle()
        datasource = StockTrackerDatasource()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addStockSymbol))
        navigationController?.navigationBar.tintColor = .white
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: 100)
    }
    
    open func addStockSymbol() {
        let alertController = UIAlertController(title: "Add Stock", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
            let count = (self.datasource?.objects?.count ?? 0)
            self.datasource?.objects?.append(alertController.textFields?[0].text ?? "$SYM")
            self.collectionView?.insertSections([count])
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Stock Symbol"
        }
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func makeLargeTitle() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.text = "Stocks"
        titleLabel.textAlignment = .left
        titleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: titleLabel.frame.size.width, height: 30))
        titleView.addSubview(titleLabel)
        navigationItem.titleView = titleView
    }
}

open class StockTrackerDatasource: NTCollectionDatasource {
    
    public override init() {
        super.init()
        objects = ["AAPL", "MSFT"]
    }
    
    ///The cell classes that will be used to render out each section.
    open override func cellClasses() -> [NTCollectionViewCell.Type] {
        return [StockViewCell.self]
    }
    
    ///Override this method to provide your list with what kind of headers should be rendered per section
    open override func headerClasses() -> [NTCollectionViewCell.Type]? {
        return [StockViewHeaderCell.self]
    }
    
    open override func numberOfItems(_ section: Int) -> Int {
        return 1
    }
    
    open override func numberOfSections() -> Int {
        return objects?.count ?? 0
    }
    
    ///For each row in your list, override this to provide it with a specific item. Access this in your DatasourceCell by overriding datasourceItem.
    open override func item(_ indexPath: IndexPath) -> Any? {
        return objects?[indexPath.section]
    }
    
    ///If your headers need a special item, return it here.
    open override func headerItem(_ section: Int) -> Any? {
        return objects?[section]
    }
}

open class StockViewHeaderCell: NTCollectionViewDefaultHeader {
    
    open let actionButton: UIButton = {
        let button = UIButton()
        button.setImage(Icon.More, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    open override func setupViews() {
        super.setupViews()
        
        separatorLineView.isHidden = true
        addSubview(actionButton)
        actionButton.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 20, heightConstant: 20)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
    }
    
}

open class StockViewCell: NTCollectionViewCell, ChartDelegate {
    
    open override var datasourceItem: Any? {
        didSet {
            guard let stock = datasourceItem as? String else {
                return
            }
            setupChart(forSymbol: stock)
            
            StockKit.findQuoteInBackground(forSymbol: stock) { (stock) in
                self.percentChangeLabel.text = stock.json["PercentChange"].stringValue
                self.currentPriceLabel.text = "$" + stock.json["LastTradePriceOnly"].stringValue
                self.tradeTimeLabel.text = stock.json["LastTradeTime"].stringValue
                if let text = self.percentChangeLabel.text {
                    if text.contains("+") {
                        self.percentChangeLabel.textColor = Color.Green.P500
                    } else {
                        self.percentChangeLabel.textColor = Color.Red.P500
                    }
                }
            }
        }
    }
    
    fileprivate var labelLeadingMarginConstraint: NSLayoutConstraint!
    
    open let percentChangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightMedium)
        return label
    }()
    
    open let currentPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightText
        return label
    }()
    
    open let tradeTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightText
        return label
    }()
    
    open let scrollLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.isHidden = true
        return label
    }()
    
    open let stockChart: Chart = {
        let chart = Chart()
        chart.axesColor = .white
        chart.bottomInset = 0
        chart.labelColor = .white
        chart.showXLabelsAndGrid = false
        return chart
    }()
    
    open override func setupViews() {
        super.setupViews()
        
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = Color.Black.lighter(by: 15)
        addSubview(percentChangeLabel)
        addSubview(currentPriceLabel)
        addSubview(tradeTimeLabel)
        addSubview(stockChart)
        addSubview(scrollLabel)
        stockChart.delegate = self
        
        percentChangeLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: stockChart.leftAnchor, topConstant: 5, leftConstant: 16, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 40)
        currentPriceLabel.anchor(percentChangeLabel.bottomAnchor, left: percentChangeLabel.leftAnchor, bottom: nil, right: percentChangeLabel.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        tradeTimeLabel.anchor(currentPriceLabel.bottomAnchor, left: currentPriceLabel.leftAnchor, bottom: nil, right: currentPriceLabel.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        stockChart.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 200, heightConstant: 90)
        
        labelLeadingMarginConstraint = scrollLabel.anchorWithReturnAnchors(stockChart.topAnchor, left: stockChart.leftAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)[1]
    }
    
    open func setupChart(forSymbol symbol: String) {
        StockKit.findHistoricPricesInBackground(forSymbol: symbol, beginAt: Date().addMonth(-1)) { (stock) in
            print(stock.json)
            
            let stockValues = stock.json["data"].array?.map { (json) -> Dictionary<String, Any> in
                let dateString = json.array?[6].stringValue
                let close = json.array?[10].floatValue
                return ["date": Date.fromString(strDate: dateString!, format: "YYYY-MM-DD")!, "close": close!]
            }
            
            var serieData: [Float] = []
            var labels: [Float] = []
            var labelsAsString: Array<String> = []
            
            // Date formatter to retrieve the month names
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM"
            
            for (i, value) in stockValues!.enumerated() {
                
                serieData.append(value["close"] as! Float)
                
                // Use only one label for each month
                let month = Int(dateFormatter.string(from: value["date"] as! Date))!
                let monthAsString:String = dateFormatter.monthSymbols[month - 1]
                if (labels.count == 0 || labelsAsString.last != monthAsString) {
                    labels.append(Float(i))
                    labelsAsString.append(monthAsString)
                }
            }
            if serieData.count <= 0 {
                return
            }
            let series = ChartSeries(serieData)
            series.area = true
            series.color = Color.BlueGray.P400
            
            // Configure chart layout
            
            self.stockChart.lineWidth = 0.5
            self.stockChart.labelFont = UIFont.systemFont(ofSize: 12)
            self.stockChart.xLabels = labels
            self.stockChart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                return labelsAsString[labelIndex]
            }
            self.stockChart.xLabelsTextAlignment = .center
            self.stockChart.yLabelsOnRightSide = true
            // Add some padding above the x-axis
            self.stockChart.minY = (serieData.min() ?? 0) - 5
            self.stockChart.add(series)
        }
    }
    
    // Chart delegate
    
    open func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        if indexes.count <= 0 {
            return
        }
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            scrollLabel.text = numberFormatter.string(from: NSNumber(value: value))
            scrollLabel.isHidden = false
            
            stockChart.labelColor = .clear
            stockChart.highlightLineColor = .white
            
            // Align the label to the touch left position, centered
            let constant = left - (scrollLabel.frame.width / 2)
            labelLeadingMarginConstraint.constant = constant
        }
        
    }
    
    public func didEndTouchingChart(_ chart: Chart) {
        scrollLabel.isHidden = false
        stockChart.labelColor = .white
        stockChart.highlightLineColor = .clear
    }
    
    public func didFinishTouchingChart(_ chart: Chart) {
        
    }
}
