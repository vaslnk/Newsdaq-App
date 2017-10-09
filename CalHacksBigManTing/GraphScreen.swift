//
//  CustomUnitsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class GraphScreen: UIViewController {
    
    
    fileprivate var chart: Chart? // arc
    var stck = String()
    var indicator = UIActivityIndicatorView()
    var stockdates: [Stock]?
    var articles: [String: Article]?
    let calendar = Calendar.current
    var displayFormatter = DateFormatter()
    var readFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.40, green:1.00, blue:0.60, alpha:1.0)
        activityIndicator()
        indicator.startAnimating()
        self.navigationItem.title = stck
        readFormatter.dateFormat = "dd.MM.yyyy"
        displayFormatter.dateFormat = "dd.MM.yyyy"
        downloadStocks(completionHandler: {finished in
            if finished == true {
                self.downloadArticles(completionHandler: {finished2 in
                    if finished2 == true {
                        self.graph()
                    }
                })
            }
        })
    }

    func filler(_ date: Date) -> ChartAxisValueDate {
        let filler = ChartAxisValueDate(date: date, formatter: displayFormatter)
        filler.hidden = true
        return filler
    }

    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    
    func downloadStocks(completionHandler: @escaping (Bool?) -> Void) {
        getappleData(stock: stck, completionHandler: {stockdata, error in
            if let stockdata = stockdata {
                parseStockJson(data: stockdata, completionHandler: {stockdates, error in
                    if let stockdates = stockdates {
                        self.stockdates = stockdates
                        completionHandler(true)
                    }
                })
            }
        })
    }
    
    func downloadArticles(completionHandler: @escaping (Bool?) -> Void) {
        getAppleArticles(stock: self.stck, completionHandler: {articlesData, error in
            if let articlesData = articlesData {
                parseArticlesJson(data: articlesData, completionHandler: {articlesArray, error in
                    if let articlesArray = articlesArray {
                        self.articles = self.articlesArrayToDictionary(articlesArray: articlesArray)
                        completionHandler(true)
                    }
                })
            }
        })
    }
    
    func articlesArrayToDictionary(articlesArray: [Article]) -> [String: Article] {
        var articles = [String: Article]()
        for article in articlesArray {
            self.dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateHere = self.dateFormatter.date(from: article.date)!
            self.dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateStrHere = self.dateFormatter.string(from: dateHere)
            articles[dateStrHere] = article
        }
        return articles
    }
    
    func graph() {
        if let stockdates = stockdates, let articles = articles {
            var chartPoints = [ChartPoint]()
            var minV = 500
            var maxV = 0
            var startDate = Date()
            var endDate = Date(timeIntervalSince1970: 0)
            for stockdate in stockdates {
                let index = stockdate.DateStamp.index(stockdate.DateStamp.startIndex, offsetBy: 10)
                var dateStr = stockdate.DateStamp.substring(to: index)
                self.dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = self.dateFormatter.date(from: dateStr)!
                startDate = min(startDate, date)
                endDate = max(endDate, date)
                self.dateFormatter.dateFormat = "dd.MM.yyyy"
                dateStr = self.dateFormatter.string(from: date)
                minV = min(minV, Int(stockdate.Close))
                maxV = max(maxV, Int(stockdate.Close))
                chartPoints.append(self.createChartPoint(dateStr: dateStr, percent: stockdate.Close, readFormatter: self.readFormatter, displayFormatter: self.displayFormatter))
            }
            
            let yValues = stride(from: minV - 10, through: maxV + 10, by: 10).map {ChartAxisValuePercent($0, labelSettings: labelSettings)}
            
            var xValues = [ChartAxisValue]()
            self.dateFormatter.dateFormat = "dd.MM.yyyy"
            while startDate <= endDate {
                xValues.append(self.createDateAxisValue(self.dateFormatter.string(from: startDate), readFormatter: self.readFormatter, displayFormatter: self.displayFormatter))
                startDate = self.calendar.date(byAdding: .month, value: 1, to: startDate)!
            }
            
            
            
            let notificationViewWidth: CGFloat = Env.iPad ? 30 : 20
            let notificationViewHeight: CGFloat = Env.iPad ? 30 : 20
            
            let notificationGenerator = {[weak self] (chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
                let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
                
                let s = chartPoint.x.labels.first?.text
                if let article = articles[s!] {
                    let articleTitle = article.title
                    let polarityScore = article.bodyPolarityScore
                    let titlePolarityScore = article.titlePolarityScore
                    let bodyPolarityWord = article.bodyPolarity
                    let titlePolarityWord = article.titlePolarity
                    let articleURL = article.URL
                    
                    
                    let chartPointView = HandlingView(frame: CGRect(x: screenLoc.x + 5, y: screenLoc.y - notificationViewHeight - 5, width: notificationViewWidth, height: notificationViewHeight))
                    let label = UILabel(frame: chartPointView.bounds)
                    label.layer.cornerRadius = Env.iPad ? 15 : 10
                    label.clipsToBounds = true
                    label.backgroundColor = UIColor.white
                    label.textAlignment = NSTextAlignment.center
                    label.font = UIFont.boldSystemFont(ofSize: Env.iPad ? 18 : 14)
                    if bodyPolarityWord == "positive" {
                        label.text = "👍"
                    } else if bodyPolarityWord == "negative" {
                        label.text = "👎"
                    } else {
                        label.text = "😐"
                    }
                    chartPointView.addSubview(label)
                    label.transform = CGAffineTransform(scaleX: 0, y: 0)
                    
                    chartPointView.movedToSuperViewHandler = {
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                            label.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }, completion: nil)
                    }
                    
                    chartPointView.touchHandler = {
                        
                        let title = article.title
                        let message = "The article is \(bodyPolarityWord) with the title polarity \(titlePolarityWord) of score \(titlePolarityScore) and body polarity of score \(polarityScore).Date: \(s!). URL: \(articleURL)"
                        let ok = "Ok"
                        
                        if #available(iOS 8.0, *) {
                            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: ok, style: UIAlertActionStyle.default, handler: nil))
                            self!.present(alert, animated: true, completion: nil)
                            
                        } else {
                            let alert = UIAlertView()
                            alert.title = title
                            alert.message = message
                            alert.addButton(withTitle: ok)
                            alert.show()
                        }
                    }
                    
                    return chartPointView
                }
                return nil
            }
            
            
            
            let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Date", settings: labelSettings))
            let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Stock Market Price", settings: labelSettings.defaultVertical()))
            let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
            var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
            chartSettings.trailing = 80
            
            // Set a fixed (horizontal) scrollable area 2x than the original width, with zooming disabled.
            chartSettings.zoomPan.maxZoomX = 2
            chartSettings.zoomPan.minZoomX = 2
            chartSettings.zoomPan.minZoomY = 1
            chartSettings.zoomPan.maxZoomY = 1
            
            let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
            let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
            
            let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, lineWidth: 2, animDuration: 1, animDelay: 0)
            
            let chartPointsNotificationsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: notificationGenerator, displayDelay: 1, mode: .custom)
            // To preserve the offset of the notification views from the chart point they represent, during transforms, we need to pass mode: .custom along with this custom transformer.
            chartPointsNotificationsLayer.customTransformer = {(model, view, layer) -> Void in
                let screenLoc = layer.modelLocToScreenLoc(x: model.chartPoint.x.scalar, y: model.chartPoint.y.scalar)
                view.frame.origin = CGPoint(x: screenLoc.x + 5, y: screenLoc.y - notificationViewHeight - 5)
            }
            
            // delayInit parameter is needed by some layers for initial zoom level to work correctly. Setting it to true allows to trigger drawing of layer manually (in this case, after the chart is initialized). This obviously needs improvement. For now it's necessary.
            let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], delayInit: true)
            
            let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth: 0.3)
            let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
            
            let chart = Chart(
                frame: chartFrame,
                innerFrame: innerFrame,
                settings: chartSettings,
                layers: [
                    xAxisLayer,
                    yAxisLayer,
                    guidelinesLayer,
                    chartPointsLineLayer,
                    chartPointsNotificationsLayer]
            )
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
            self.view.addSubview(chart.view)
            chartPointsLineLayer.initScreenLines(chart)
            self.chart = chart
        }
    }
    
    func createChartPoint(dateStr: String, percent: Double, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartPoint {
        return ChartPoint(x: createDateAxisValue(dateStr, readFormatter: readFormatter, displayFormatter: displayFormatter), y: ChartAxisValue(scalar: percent))
    }
    
    func createDateAxisValue(_ dateStr: String, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartAxisValue {
        let date = readFormatter.date(from: dateStr)!
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, rotation: 45, rotationKeep: .top)
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }
    
    class ChartAxisValuePercent: ChartAxisValueDouble {
        override var description: String {
            return "\(formatter.string(from: NSNumber(value: scalar))!)"
        }
    }
}

